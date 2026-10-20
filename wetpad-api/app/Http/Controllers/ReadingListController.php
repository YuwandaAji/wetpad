<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ReadingListController extends Controller
{
    // id yang dikirim ke aplikasi = uid buatan aplikasi, atau id database kalau tidak ada
    private function shape($l, $ids): array
    {
        return [
            'id' => (string) ($l->uid ?: $l->id),
            'name' => $l->name,
            'story_ids' => collect($ids)->map(fn ($i) => (string) $i)->values(),
            'is_public' => (bool) $l->is_public,
        ];
    }

    private function find(Request $r, string $key)
    {
        return DB::table('reading_lists')
            ->where('user_id', $r->user()->id)
            ->where(function ($w) use ($key) {
                $w->where('uid', $key);
                if (ctype_digit($key)) {
                    $w->orWhere('id', (int) $key);
                }
            })
            ->first();
    }

    // GET /reading-lists
    public function index(Request $r)
    {
        $lists = DB::table('reading_lists')->where('user_id', $r->user()->id)->orderBy('id')->get();
        $items = DB::table('reading_list_items')
            ->whereIn('list_id', $lists->pluck('id'))
            ->get()
            ->groupBy('list_id');

        return $this->ok($lists->map(
            fn ($l) => $this->shape($l, $items->get($l->id, collect())->pluck('story_id'))
        )->values());
    }

    // PUT /reading-lists/{key} : buat atau perbarui (nama, publik, isi daftar)
    public function upsert(Request $r, string $key)
    {
        $v = $r->validate([
            'name' => 'required|string|max:100',
            'story_ids' => 'array',
            'story_ids.*' => 'integer|exists:stories,id',
            'is_public' => 'boolean',
        ]);

        $list = $this->find($r, $key);

        if (!$list) {
            $id = DB::table('reading_lists')->insertGetId([
                'user_id' => $r->user()->id,
                'uid' => $key,
                'name' => $v['name'],
                'is_public' => $v['is_public'] ?? true,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        } else {
            $id = $list->id;
            DB::table('reading_lists')->where('id', $id)->update([
                'name' => $v['name'],
                'is_public' => $v['is_public'] ?? $list->is_public,
                'updated_at' => now(),
            ]);
        }

        DB::transaction(function () use ($id, $v) {
            DB::table('reading_list_items')->where('list_id', $id)->delete();
            $rows = collect($v['story_ids'] ?? [])->unique()
                ->map(fn ($s) => ['list_id' => $id, 'story_id' => $s])->all();
            if ($rows) {
                DB::table('reading_list_items')->insert($rows);
            }
        });

        return $this->ok();
    }

    // DELETE /reading-lists/{key}
    public function destroy(Request $r, string $key)
    {
        $list = $this->find($r, $key);
        if ($list) {
            DB::table('reading_lists')->where('id', $list->id)->delete(); // isi daftar ikut terhapus
        }
        return $this->ok();
    }
}