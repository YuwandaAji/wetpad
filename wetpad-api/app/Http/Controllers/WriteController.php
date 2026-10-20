<?php

namespace App\Http\Controllers;

use App\Models\{Part, Story, UserNotification};
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class WriteController extends Controller
{
    private function own(Request $r, $id): Story
    {
        $s = Story::findOrFail($id);
        abort_unless($s->author_id === $r->user()->id, 403, 'Ini bukan ceritamu.');
        return $s;
    }

    private function shape(Story $s): array
    {
        return [
            'id' => $s->id,
            'title' => $s->title,
            'description' => $s->description ?? '',
            'cover_url' => $s->cover_url,
            'genre' => $s->genre,
            'tags' => $s->tags ?? [],
            'status' => $s->status,
            'parts_count' => $s->parts_count ?? $s->parts()->count(),
            'created_at' => $s->created_at->toIso8601String(),
        ];
    }

    // GET /stories/mine?status=published|draft
    public function mine(Request $r)
    {
        $q = Story::withCount('parts')->where('author_id', $r->user()->id)->latest('updated_at');
        if ($r->status === 'published') $q->has('parts');
        if ($r->status === 'draft') $q->doesntHave('parts');
        return $this->ok($q->get()->map(fn ($s) => $this->shape($s))->values());
    }

    // POST /stories  (multipart: title, description, cover)
    public function store(Request $r)
    {
        $v = $r->validate([
            'title' => 'required|string|max:200',
            'description' => 'nullable|string|max:2000',
            'genre' => 'nullable|string|max:50',
            'cover' => 'nullable|image|max:4096',
        ]);
        $story = Story::create([
            'author_id' => $r->user()->id,
            'title' => $v['title'],
            'description' => $v['description'] ?? null,
            'genre' => $v['genre'] ?? null,
            'cover_url' => $this->saveCover($r),
            'tags' => [],
        ]);
        return $this->ok($this->shape($story), null, 201);
    }

    // PUT|POST /stories/{id}
    public function update(Request $r, $id)
    {
        $s = $this->own($r, $id);
        $v = $r->validate([
            'title' => 'sometimes|required|string|max:200',
            'description' => 'sometimes|nullable|string|max:2000',
            'genre' => 'sometimes|nullable|string|max:50',
            'tags' => 'sometimes|array|max:20',
            'tags.*' => 'string|max:40',
            'status' => 'sometimes|in:ongoing,completed',
            'cover' => 'nullable|image|max:4096',
        ]);
        unset($v['cover']);
        if ($url = $this->saveCover($r)) $v['cover_url'] = $url;
        $s->update($v);
        return $this->ok($this->shape($s->fresh()));
    }

    // DELETE /stories/{id}
    public function destroy(Request $r, $id)
    {
        $this->own($r, $id)->delete(); // parts, votes, comments cascade
        return $this->ok();
    }

    // POST /stories/{id}/parts {title?, content}
    public function addPart(Request $r, $id)
    {
        $s = $this->own($r, $id);
        $v = $r->validate(['title' => 'nullable|string|max:200', 'content' => 'required|string']);

        $part = DB::transaction(function () use ($s, $v) {
            $n = (int) Part::where('story_id', $s->id)->lockForUpdate()->max('part_number') + 1;
            return Part::create([
                'story_id' => $s->id,
                'part_number' => $n,
                'title' => trim($v['title'] ?? '') ?: "Bab $n",
                'content' => $v['content'],
            ]);
        });
        $s->touch();

        // tell everyone who has this story in their library
        DB::table('library')->where('story_id', $s->id)->pluck('user_id')->each(
            fn ($uid) => UserNotification::notifyUser($uid, $r->user()->id, 'story_update', $s->title,
                "{$r->user()->username} memperbarui cerita dengan Bab {$part->part_number}.", $s->id, $part->id));

        return $this->ok(['id' => $part->id, 'part_number' => $part->part_number, 'title' => $part->title], null, 201);
    }

    // PUT /parts/{id} {title?, content?}
    public function updatePart(Request $r, $id)
    {
        $p = Part::findOrFail($id);
        $this->own($r, $p->story_id);
        $p->update($r->validate([
            'title' => 'sometimes|required|string|max:200',
            'content' => 'sometimes|required|string',
        ]));
        return $this->ok();
    }

    // DELETE /parts/{id}  (renumbers the rest)
    public function destroyPart(Request $r, $id)
    {
        $p = Part::findOrFail($id);
        $this->own($r, $p->story_id);
        DB::transaction(function () use ($p) {
            $p->delete();
            Part::where('story_id', $p->story_id)->where('part_number', '>', $p->part_number)
                ->orderBy('part_number')->get()->each->decrement('part_number');
        });
        return $this->ok();
    }

    private function saveCover(Request $r): ?string
    {
        if (!$r->hasFile('cover')) return null;
        $path = $r->file('cover')->store('covers', 'public');
        return asset('storage/' . $path);
    }
}