<?php

namespace App\Http\Controllers;

use App\Models\{Story, User, UserNotification};
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ProfileController extends Controller
{
    // GET /users/{username}  (token optional)
    public function show(Request $r, string $username)
    {
        $u = User::where('username', $username)->firstOrFail();
        $viewer = $r->user('sanctum');
        $isMe = $viewer && $viewer->id === $u->id;

        $stories = Story::select('stories.*')
            ->selectSub(DB::table('parts')->whereColumn('parts.story_id', 'stories.id')
                ->selectRaw('coalesce(sum(reads_count),0)'), 'reads_total')
            ->selectSub(DB::table('votes')->join('parts', 'parts.id', '=', 'votes.part_id')
                ->whereColumn('parts.story_id', 'stories.id')->selectRaw('count(*)'), 'stars_total')
            ->withCount('parts')
            ->where('author_id', $u->id)
            ->when(!$isMe, fn ($q) => $q->has('parts'))   // other people only see published
            ->latest('updated_at')->get();

        $lists = DB::table('reading_lists')->where('user_id', $u->id)
            ->when(!$isMe, fn ($q) => $q->where('is_public', true))->get();
        $items = DB::table('reading_list_items')
            ->join('stories', 'stories.id', '=', 'reading_list_items.story_id')
            ->whereIn('list_id', $lists->pluck('id'))
            ->get(['list_id', 'stories.id', 'stories.title', 'stories.cover_url'])
            ->groupBy('list_id');

        return $this->ok([
            'id' => $u->id,
            'username' => $u->username,
            'avatar_url' => $u->avatar_url,
            'about' => $u->about ?? '',
            'joined_at' => $u->created_at?->toIso8601String(),
            'is_me' => $isMe,
            'is_following' => $viewer
                ? DB::table('follows')->where(['follower_id' => $viewer->id, 'followed_id' => $u->id])->exists()
                : false,
            'followers_count' => DB::table('follows')->where('followed_id', $u->id)->count(),
            'following_count' => DB::table('follows')->where('follower_id', $u->id)->count(),
            'stories' => $stories->map(fn ($s) => [
                'id' => $s->id,
                'title' => $s->title,
                'description' => $s->description,
                'cover_url' => $s->cover_url,
                'tags' => $s->tags ?? [],
                'parts_count' => $s->parts_count,
                'reads_total' => (int) $s->reads_total,
                'stars_total' => (int) $s->stars_total,
            ])->values(),
            'reading_lists' => $lists->map(fn ($l) => [
                'id' => $l->id,
                'name' => $l->name,
                'stories' => $items->get($l->id, collect())->map(fn ($x) => [
                    'id' => $x->id, 'title' => $x->title, 'cover_url' => $x->cover_url,
                ])->values(),
            ])->values(),
        ]);
    }

    // PUT /auth/profile  {about}
    public function update(Request $r)
    {
        $v = $r->validate([
            'about' => 'sometimes|nullable|string|max:2000',
            'avatar_url' => 'sometimes|nullable|string|max:500',
        ]);
        $r->user()->update($v);
        return $this->ok($r->user()->fresh());
    }

    // POST /users/{username}/follow
    public function follow(Request $r, string $username)
    {
        $target = User::where('username', $username)->firstOrFail();
        $me = $r->user();
        abort_if($target->id === $me->id, 422, 'Tidak bisa mengikuti diri sendiri.');

        $inserted = DB::table('follows')->insertOrIgnore([
            'follower_id' => $me->id, 'followed_id' => $target->id,
            'created_at' => now(), 'updated_at' => now(),
        ]);
        if ($inserted) {
            UserNotification::notifyUser($target->id, $me->id, 'follow',
                "{$me->username} mulai mengikuti kamu", 'Lihat profilnya dan ikuti balik.');
        }
        return $this->ok(['is_following' => true, 'followers_count' => $this->followers($target->id)]);
    }

    // DELETE /users/{username}/follow
    public function unfollow(Request $r, string $username)
    {
        $target = User::where('username', $username)->firstOrFail();
        DB::table('follows')->where(['follower_id' => $r->user()->id, 'followed_id' => $target->id])->delete();
        return $this->ok(['is_following' => false, 'followers_count' => $this->followers($target->id)]);
    }

    // GET /users/{username}/followers   |   /following
    public function followersList(Request $r, string $username)
    {
        $u = User::where('username', $username)->firstOrFail();
        return $this->ok($this->cards(
            DB::table('follows')->where('followed_id', $u->id)->pluck('follower_id'), $r));
    }

    public function followingList(Request $r, string $username)
    {
        $u = User::where('username', $username)->firstOrFail();
        return $this->ok($this->cards(
            DB::table('follows')->where('follower_id', $u->id)->pluck('followed_id'), $r));
    }

    // ---- Percakapan (posts on a profile) ----

    // GET /users/{username}/posts
    public function posts(string $username)
    {
        $u = User::where('username', $username)->firstOrFail();
        $rows = DB::table('profile_posts as p')
            ->join('users as a', 'a.id', '=', 'p.author_id')
            ->where('p.profile_id', $u->id)
            ->orderByDesc('p.id')
            ->get(['p.id', 'p.parent_id', 'p.body', 'p.created_at', 'a.username as author']);

        $shape = fn ($x) => [
            'id' => (string) $x->id,
            'author' => $x->author,
            'body' => $x->body,
            'created_at' => \Carbon\Carbon::parse($x->created_at)->toIso8601String(),
        ];
        $replies = $rows->whereNotNull('parent_id')->sortBy('id')->groupBy('parent_id');

        return $this->ok($rows->whereNull('parent_id')->map(fn ($x) => $shape($x) + [
            'replies' => $replies->get($x->id, collect())->map($shape)->values(),
        ])->values());
    }

    // POST /users/{username}/posts  {body, parent_id?}
    public function storePost(Request $r, string $username)
    {
        $u = User::where('username', $username)->firstOrFail();
        $v = $r->validate([
            'body' => 'required|string|max:2000',
            'parent_id' => 'nullable|integer|exists:profile_posts,id',
        ]);
        if (!empty($v['parent_id'])) {
            abort_unless(DB::table('profile_posts')
                ->where(['id' => $v['parent_id'], 'profile_id' => $u->id])->exists(), 422, 'Postingan induk tidak valid.');
        }
        $id = DB::table('profile_posts')->insertGetId([
            'profile_id' => $u->id, 'author_id' => $r->user()->id,
            'parent_id' => $v['parent_id'] ?? null, 'body' => $v['body'],
            'created_at' => now(), 'updated_at' => now(),
        ]);
        if ($r->user()->id !== $u->id) {
            UserNotification::notifyUser($u->id, $r->user()->id, 'comment',
                "{$r->user()->username} menulis di profilmu", mb_substr($v['body'], 0, 120));
        }
        return $this->ok(['id' => (string) $id], null, 201);
    }

    // DELETE /posts/{id}   (author or profile owner)
    public function destroyPost(Request $r, $id)
    {
        $p = DB::table('profile_posts')->where('id', $id)->first();
        abort_unless($p, 404, 'Postingan tidak ditemukan');
        abort_unless(in_array($r->user()->id, [$p->author_id, $p->profile_id]), 403, 'Tidak diizinkan');
        DB::table('profile_posts')->where('id', $id)->delete(); // replies cascade
        return $this->ok();
    }

    private function followers(int $id): int
    {
        return DB::table('follows')->where('followed_id', $id)->count();
    }

    private function cards($ids, Request $r)
    {
        $viewer = $r->user('sanctum');
        $mine = $viewer
            ? DB::table('follows')->where('follower_id', $viewer->id)->pluck('followed_id')->all()
            : [];
        return User::whereIn('id', $ids)->get()->map(fn ($u) => [
            'id' => $u->id,
            'username' => $u->username,
            'avatar_url' => $u->avatar_url,
            'followers_count' => $this->followers($u->id),
            'is_following' => in_array($u->id, $mine),
        ])->values();
    }
}