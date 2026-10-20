<?php

namespace App\Http\Controllers;

use App\Models\{Part, Story};
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class WriterController extends Controller
{
    private function card($s): array
    {
        return [
            'id' => $s->id,
            'title' => $s->title,
            'cover_url' => $s->cover_url,
            'description' => $s->description,
            'genre' => $s->genre,
            'tags' => $s->tags ?? [],
            'status' => $s->status,
            'parts_count' => (int) $s->parts_count,
            'reads_total' => (int) ($s->reads_total ?? 0),
            'created_at' => $s->created_at?->toIso8601String(),
            'updated_at' => $s->updated_at?->toIso8601String(),
        ];
    }

    // GET /my/stories : cerita milik penulis yang login (tab Series)
    public function mine(Request $r)
    {
        $list = Story::where('author_id', $r->user()->id)
            ->withCount('parts')
            ->withSum('parts as reads_total', 'reads_count')
            ->orderByDesc('updated_at')
            ->get();

        return $this->ok($list->map(fn ($s) => $this->card($s))->values());
    }

    // POST /stories : buat cerita baru (JSON atau multipart dengan file "cover")
    public function store(Request $r)
    {
        $v = $r->validate([
            'title' => 'required|string|max:200',
            'description' => 'nullable|string|max:5000',
            'genre' => 'nullable|string|max:50',
            'tags' => 'nullable|array|max:20',
            'tags.*' => 'string|max:30',
            'status' => 'nullable|in:ongoing,completed',
            'cover_url' => 'nullable|string|max:500',
            'cover' => 'nullable|file|mimes:jpg,jpeg,png,webp|max:4096',
        ]);

        $cover = $v['cover_url'] ?? null;
        if ($r->hasFile('cover')) {
            $file = $r->file('cover');
            $name = Str::uuid() . '.' . ($file->guessExtension() ?: 'jpg');
            $file->move(public_path('covers'), $name); // tanpa symlink, aman di Windows
            $cover = $r->getSchemeAndHttpHost() . '/covers/' . $name;
        }

        $s = Story::create([
            'author_id' => $r->user()->id,
            'title' => $v['title'],
            'description' => $v['description'] ?? null,
            'genre' => $v['genre'] ?? 'Acak',
            'tags' => $v['tags'] ?? [],
            'status' => $v['status'] ?? 'ongoing',
            'cover_url' => $cover
                ?? 'https://picsum.photos/seed/' . urlencode($v['title']) . '/300/450',
        ]);
        $s->loadCount('parts');

        return $this->ok($this->card($s), 'Cerita dibuat', 201);
    }

    // POST /stories/{id}/parts : tambah bab baru (hanya penulisnya)
    public function addPart(Request $r, $id)
    {
        $story = Story::where('id', $id)->where('author_id', $r->user()->id)->firstOrFail();

        $v = $r->validate([
            'title' => 'required|string|max:200',
            'content' => 'required|string',
        ]);

        $n = (int) Part::where('story_id', $story->id)->max('part_number') + 1;
        $part = Part::create([
            'story_id' => $story->id,
            'part_number' => $n,
            'title' => $v['title'],
            'content' => $v['content'],
        ]);
        $story->touch();

        return $this->ok([
            'id' => $part->id,
            'part_number' => $part->part_number,
            'title' => $part->title,
        ], 'Bab ditambahkan', 201);
    }
}