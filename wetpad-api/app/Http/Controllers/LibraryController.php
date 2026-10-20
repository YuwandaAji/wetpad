<?php

namespace App\Http\Controllers;

use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class LibraryController extends Controller
{
    // GET /library : cerita di perpustakaan pengguna
    public function index(Request $r)
    {
        $rows = DB::table('library')
            ->join('stories', 'stories.id', '=', 'library.story_id')
            ->join('users', 'users.id', '=', 'stories.author_id')
            ->leftJoin('parts as lp', 'lp.id', '=', 'library.last_part_id')
            ->where('library.user_id', $r->user()->id)
            ->select([
                'stories.id', 'stories.title', 'stories.cover_url', 'stories.description',
                'stories.updated_at as story_updated_at',
                'users.username as author',
                'library.archived', 'library.offline', 'library.added_at', 'library.last_read_at',
                'lp.part_number as last_part_number',
                DB::raw('(select count(*) from parts where parts.story_id = stories.id) as parts_count'),
                DB::raw('(select max(created_at) from parts where parts.story_id = stories.id) as last_part_at'),
            ])
            ->orderByRaw('COALESCE(library.last_read_at, library.added_at) DESC')
            ->get();

        $iso = fn ($d) => $d ? Carbon::parse($d)->toIso8601String() : null;

        return $this->ok($rows->map(function ($x) use ($iso) {
            $progress = ($x->parts_count > 0 && $x->last_part_number)
                ? min(1, $x->last_part_number / $x->parts_count)
                : 0;

            return [
                'id' => (string) $x->id,
                'title' => $x->title,
                'author' => $x->author,
                'cover_url' => $x->cover_url,
                'description' => $x->description,
                'progress' => round($progress, 3),
                'is_offline' => (bool) $x->offline,
                'is_archived' => (bool) $x->archived,
                'last_read_at' => $iso($x->last_read_at ?? $x->added_at),
                'added_at' => $iso($x->added_at),
                'updated_at' => $iso($x->last_part_at ?? $x->story_updated_at),
            ];
        })->values());
    }

    // POST /library {story_id} : tombol "Tambahkan ke Perpustakaan"
    public function store(Request $r)
    {
        $r->validate(['story_id' => 'required|exists:stories,id']);
        DB::table('library')->updateOrInsert(
            ['user_id' => $r->user()->id, 'story_id' => $r->story_id], []);
        return $this->ok(null, 'Ditambahkan ke perpustakaan', 201);
    }

    // PUT /library/{storyId} : tambah atau perbarui (arsip, offline, terakhir dibaca)
    public function upsert(Request $r, $storyId)
    {
        abort_unless(DB::table('stories')->where('id', $storyId)->exists(), 404, 'Cerita tidak ditemukan');

        $v = $r->validate([
            'is_archived' => 'sometimes|boolean',
            'is_offline' => 'sometimes|boolean',
            'last_read_at' => 'sometimes|nullable|date',
        ]);

        $values = [];
        if (array_key_exists('is_archived', $v)) {
            $values['archived'] = $v['is_archived'];
        }
        if (array_key_exists('is_offline', $v)) {
            $values['offline'] = $v['is_offline'];
        }
        if (!empty($v['last_read_at'])) {
            $values['last_read_at'] = Carbon::parse($v['last_read_at'])->utc()->format('Y-m-d H:i:s');
        }

        DB::table('library')->updateOrInsert(
            ['user_id' => $r->user()->id, 'story_id' => $storyId], $values);
        return $this->ok();
    }

    // DELETE /library/{storyId} : hapus dari perpustakaan
    public function destroy(Request $r, $storyId)
    {
        DB::table('library')
            ->where(['user_id' => $r->user()->id, 'story_id' => $storyId])
            ->delete();
        return $this->ok();
    }

    // PUT /library/{storyId}/progress : dipanggil pembaca tiap pindah bab
    public function progress(Request $r, $storyId)
    {
        $r->validate(['last_part_id' => 'required|exists:parts,id']);
        DB::table('library')
            ->where(['user_id' => $r->user()->id, 'story_id' => $storyId])
            ->update(['last_part_id' => $r->last_part_id, 'last_read_at' => now()]);
        return $this->ok();
    }
}