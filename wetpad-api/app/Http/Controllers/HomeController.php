<?php

namespace App\Http\Controllers;

use App\Models\Story;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class HomeController extends Controller
{
    private function stories()
    {
        return Story::query()
            ->select('stories.*')
            ->addSelect([
                'votes_total' => DB::table('votes')
                    ->join('parts', 'parts.id', '=', 'votes.part_id')
                    ->whereColumn('parts.story_id', 'stories.id')
                    ->selectRaw('count(*)'),
            ])
            ->with('author:id,username,avatar_url')
            ->withCount('parts')
            ->withSum('parts as reads_total', 'reads_count');
    }

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
            'author' => $s->author?->username,
            'parts_count' => (int) $s->parts_count,
            'reads_total' => (int) $s->reads_total,
            'votes_total' => (int) $s->votes_total,
        ];
    }

    public function index(Request $r)
    {
        $user = auth('sanctum')->user();
        $card = fn ($s) => $this->card($s);
        $all = $this->stories()->get();

        // Top picks: paling banyak dibaca
        $top = $all->sortByDesc('reads_total')->take(8)->values()->map($card);

        // Daftar per genre: 4 genre dengan cerita terbanyak
        $sections = $all->filter(fn ($s) => $s->genre)
            ->groupBy('genre')
            ->map(fn ($g, $genre) => [
                'key' => Str::slug($genre),
                'title' => $genre,
                'stories' => $g->sortByDesc('reads_total')->take(10)->values()->map($card),
            ])
            ->sortByDesc(fn ($sec) => count($sec['stories']))
            ->take(4)->values();

        // Rekomendasi: sesuai genre pilihan pengguna, kalau kosong semua cerita
        $prefs = $user?->genres ?? [];
        $rec = $prefs ? $all->filter(fn ($s) => in_array($s->genre, $prefs, true)) : $all;
        if ($rec->isEmpty()) {
            $rec = $all;
        }
        $recommended = $rec->sortByDesc('votes_total')->take(10)->values()->map($card);

        return $this->ok([
            'top_picks' => $top,
            'sections' => $sections,
            'recommended' => $recommended,
        ]);
    }
}