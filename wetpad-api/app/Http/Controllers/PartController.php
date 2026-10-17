<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\{Part, Comment};
use Illuminate\Support\Facades\DB;

class PartController extends Controller
{
    public function show($id)
    {
        $p = Part::with('story.author:id,username')->findOrFail($id); 
        $p->increment('reads_count');

        $sibling = fn($op, $dir) => Part::where('story_id', $p->story_id)
            ->where('part_number', $op, $p->part_number)
            ->orderBy('part_number', $dir)->value('id');

        $user = auth('sanctum')->user();

        return $this->ok([
            'id' => $p->id,
            'story_id' => $p->story_id,
            'story_title' => $p->story->title,            
            'cover_url' => $p->story->cover_url,          
            'author' => $p->story->author->username,      
            'reads' => $p->reads_count,                   
            'part_number' => $p->part_number,
            'title' => $p->title,
            'content' => $p->content,
            'prev_id' => $sibling('<', 'desc'),
            'next_id' => $sibling('>', 'asc'),
            'votes' => DB::table('votes')->where('part_id', $p->id)->count(),
            'comments_count' => Comment::where('part_id', $p->id)->count(),
            'paragraph_comments' => Comment::where('part_id', $p->id)
            ->whereNotNull('paragraph_index')
            ->selectRaw('paragraph_index as idx, count(*) as total')
            ->groupBy('paragraph_index')->get()
            ->map(fn ($x) => ['index' => (int) $x->idx, 'count' => (int) $x->total])
            ->values(),
            'voted' => $user
                ? DB::table('votes')->where(['user_id' => $user->id, 'part_id' => $p->id])->exists()
                : false,
        ]);
    }

    public function vote(Request $r, $id)
    {
        Part::findOrFail($id);
        $key = ['user_id' => $r->user()->id, 'part_id' => $id];
        $q = DB::table('votes')->where($key);
        if ($q->exists()) { $q->delete(); $voted = false; }
        else { DB::table('votes')->insert($key); $voted = true; }
        return $this->ok([
            'voted' => $voted,
            'votes' => DB::table('votes')->where('part_id', $id)->count(),
        ]);
    }

}