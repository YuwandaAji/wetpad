<?php

namespace App\Http\Controllers;

use App\Models\Story;
use Illuminate\Support\Facades\DB;

class StoryController extends Controller
{
    public function show($id)
    {
        $s = Story::with('author:id,username,avatar_url')->findOrFail($id);
        $partIds = $s->parts()->pluck('id');
        return $this->ok([
            'id' => $s->id,
            'title' => $s->title,
            'description' => $s->description,
            'cover_url' => $s->cover_url,
            'genre' => $s->genre,
            'tags' => $s->tags ?? [],
            'status' => $s->status,
            'author' => $s->author,
            'parts_count' => $partIds->count(),
            'reads_total' => (int) $s->parts()->sum('reads_count'),
            'votes_total' => DB::table('votes')->whereIn('part_id', $partIds)->count(),
            'last_published' => \App\Models\Part::where('story_id', $s->id)->max('created_at')
        ]);
    }

    public function parts($id)
    {
        $parts = Story::findOrFail($id)->parts()
            ->get(['id', 'part_number', 'title', 'reads_count', 'created_at']);
        return $this->ok($parts);
    }

    public function recommendations($id)
    {
        $s = Story::findOrFail($id);
        $list = Story::withCount('parts')
            ->where('id', '!=', $id)
            ->orderByRaw('genre = ? desc', [$s->genre])
            ->limit(8)->get();

        return $this->ok($list->map(fn($x) => [
            'id' => $x->id,
            'title' => $x->title,
            'cover_url' => $x->cover_url,
            'description' => $x->description,
            'status' => $x->status,
            'parts_count' => $x->parts_count,
        ]));
    }
}
