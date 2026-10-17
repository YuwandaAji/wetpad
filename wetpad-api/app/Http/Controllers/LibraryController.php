<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class LibraryController extends Controller
{
    public function store(Request $r)
    {
        $r->validate(['story_id' => 'required|exists:stories,id']);
        DB::table('library')->updateOrInsert(
            ['user_id' => $r->user()->id, 'story_id' => $r->story_id], []);
        return $this->ok(null, 'Ditambahkan ke perpustakaan', 201);
    }

    public function progress(Request $r, $storyId)
    {
        $r->validate(['last_part_id' => 'required|exists:parts,id']);
        DB::table('library')
            ->where(['user_id' => $r->user()->id, 'story_id' => $storyId])
            ->update(['last_part_id' => $r->last_part_id]);
        return $this->ok();
    }
}