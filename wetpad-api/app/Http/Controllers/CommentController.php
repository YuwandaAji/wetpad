<?php

namespace App\Http\Controllers;

use App\Models\{Comment, Part};
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class CommentController extends Controller
{
    private function query($uid)
    {
        return Comment::with('user:id,username,avatar_url')
            ->withCount(['likedBy as likes_count', 'replies'])
            ->withExists(['likedBy as liked' => fn ($q) => $q->where('comment_likes.user_id', $uid)]);
    }

    private function shape($c, $authorId): array
    {
        return [
            'id' => $c->id,
            'parent_id' => $c->parent_id,
            'body' => $c->body,
            'created_at' => $c->created_at->toIso8601String(),
            'user' => [
                'id' => $c->user->id,
                'username' => $c->user->username,
                'avatar_url' => $c->user->avatar_url,
            ],
            'is_author' => (int) $c->user_id === (int) $authorId,
            'likes_count' => (int) $c->likes_count,
            'liked' => (bool) $c->liked,
            'replies_count' => (int) $c->replies_count,
        ];
    }

    // komentar tingkat atas, terbaru dulu
    public function index(Request $r, $partId)
    {
        $part = Part::with('story:id,author_id')->findOrFail($partId);
        $q = $this->query(auth('sanctum')->id())
            ->where('part_id', $partId)->whereNull('parent_id');

        $r->filled('paragraph')
            ? $q->where('paragraph_index', (int) $r->paragraph)
            : $q->whereNull('paragraph_index');

        $list = $q->orderByDesc('id')->get();
        return $this->ok($list->map(fn ($c) => $this->shape($c, $part->story->author_id)));
    }

    // balasan, terlama dulu
    public function replies($id)
    {
        $authorId = Comment::findOrFail($id)->part->story->author_id;
        $list = $this->query(auth('sanctum')->id())
            ->where('parent_id', $id)->orderBy('id')->get();
        return $this->ok($list->map(fn ($c) => $this->shape($c, $authorId)));
    }

    public function store(Request $r, $partId)
    {
        $v = $r->validate([
            'body' => 'required|string|max:1000',
            'parent_id' => 'nullable|integer|exists:comments,id',
            'paragraph_index' => 'nullable|integer|min:0',
        ]);
        $part = Part::with('story:id,author_id')->findOrFail($partId);

        $parentId = $v['parent_id'] ?? null;
        $paragraph = $v['paragraph_index'] ?? null;
        if ($parentId) {
            $parent = Comment::findOrFail($parentId);
            abort_if($parent->part_id != $partId, 422, 'Komentar induk tidak cocok');
            $parentId = $parent->parent_id ?? $parent->id; // balasan selalu 1 tingkat
            $paragraph = $parent->paragraph_index;         // balasan ikut paragraf induk
        }

        $c = Comment::create([
            'part_id' => $partId,
            'user_id' => $r->user()->id,
            'parent_id' => $parentId,
            'paragraph_index' => $paragraph,
            'body' => $v['body'],
        ]);
        $c = $this->query($r->user()->id)->find($c->id);

        return $this->ok($this->shape($c, $part->story->author_id), null, 201);
    }

    public function like(Request $r, $id)
    {
        Comment::findOrFail($id);
        $key = ['user_id' => $r->user()->id, 'comment_id' => $id];
        $q = DB::table('comment_likes')->where($key);
        if ($q->exists()) { $q->delete(); $liked = false; }
        else { DB::table('comment_likes')->insert($key); $liked = true; }

        return $this->ok([
            'liked' => $liked,
            'likes_count' => DB::table('comment_likes')->where('comment_id', $id)->count(),
        ]);
    }
}