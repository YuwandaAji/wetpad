<?php

namespace App\Http\Controllers;

use App\Models\Part;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ReactionController extends Controller
{
    private function summary($partId, $idx)
    {
        $uid = auth('sanctum')->id() ?? 0;
        return DB::table('reactions')
            ->where(['part_id' => $partId, 'paragraph_index' => $idx])
            ->selectRaw('sticker, count(*) as total, sum(user_id = ?) as mine', [$uid])
            ->groupBy('sticker')->orderByDesc('total')->get()
            ->map(fn ($r) => [
                'sticker' => (int) $r->sticker,
                'count' => (int) $r->total,
                'mine' => (int) $r->mine > 0,
            ]);
    }

    public function index($partId, $idx)
    {
        Part::findOrFail($partId);
        return $this->ok($this->summary($partId, $idx));
    }

    // pilih stiker yang sama lagi = batal; pilih yang lain = ganti
    public function store(Request $r, $partId, $idx)
    {
        $v = $r->validate(['sticker' => 'required|integer|min:0|max:23']);
        Part::findOrFail($partId);

        $key = ['user_id' => $r->user()->id, 'part_id' => $partId, 'paragraph_index' => $idx];
        $cur = DB::table('reactions')->where($key)->first();

        if ($cur && (int) $cur->sticker === (int) $v['sticker']) {
            DB::table('reactions')->where($key)->delete();
        } else {
            DB::table('reactions')->updateOrInsert($key, [
                'sticker' => $v['sticker'],
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
        return $this->ok($this->summary($partId, $idx));
    }
}