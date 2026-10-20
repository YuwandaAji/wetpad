<?php

namespace App\Http\Controllers;

use App\Models\Story;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class SearchController extends Controller
{
    private function base()
    {
        return Story::query()
            ->select('stories.*')
            ->with('author:id,username')
            ->withCount('parts')
            ->withSum('parts as reads_total', 'reads_count');
    }

    // bentuk JSON yang diharapkan SearchStory.fromJson di Flutter
    private function shape($s): array
    {
        return [
            'id' => $s->id,
            'title' => $s->title,
            'author' => $s->author?->username ?? '-',
            'cover' => $s->cover_url ?? '',
            'views' => (int) $s->reads_total,
            'parts' => (int) $s->parts_count,
            'tags' => $s->tags ?? [],
            'categories' => $s->genre ? [$s->genre] : [],
            'is_original' => false,
        ];
    }

    // GET /search?q=  : pencarian cerita (judul, deskripsi, tag, penulis)
    public function index(Request $r)
    {
        $q = trim((string) $r->query('q', ''));
        if ($q === '') {
            return $this->ok([]);
        }

        $like = '%' . addcslashes($q, '%_\\') . '%';
        $list = $this->base()
            ->where(function ($w) use ($like) {
                $w->where('stories.title', 'like', $like)
                    ->orWhere('stories.description', 'like', $like)
                    ->orWhere('stories.tags', 'like', $like)
                    ->orWhereHas('author', fn ($a) => $a->where('username', 'like', $like));
            })
            ->orderByDesc('reads_total')
            ->orderByDesc('stories.id')
            ->limit(50)
            ->get();

        return $this->ok($list->map(fn ($s) => $this->shape($s))->values());
    }

    // GET /search/categories : kategori = genre yang punya cerita
    public function categories()
    {
        $rows = Story::query()
            ->whereNotNull('genre')
            ->select('genre', DB::raw('count(*) as total'))
            ->groupBy('genre')
            ->orderByDesc('total')
            ->orderBy('genre')
            ->get();

        return $this->ok($rows->map(fn ($g) => [
            'id' => $g->genre,
            'name' => $g->genre,
            'is_originals' => false,
        ])->values());
    }

    // GET /search/feed?category=&sort=hot|new&tags=a,b
    public function feed(Request $r)
    {
        $category = (string) $r->query('category', '');
        $tags = array_filter(explode(',', (string) $r->query('tags', '')));

        $query = $this->base()->where('stories.genre', $category);
        foreach ($tags as $t) {
            $query->whereJsonContains('stories.tags', $t); // semua tag harus ada
        }

        $total = (clone $query)->count();

        $sorted = clone $query;
        if ($r->query('sort') === 'new') {
            $sorted->orderByDesc('stories.created_at');
        } else {
            $sorted->orderByDesc('reads_total');
        }
        $stories = $sorted->orderByDesc('stories.id')->limit(50)->get();

        $originals = (clone $query)->orderByDesc('reads_total')->limit(4)->get();

        return $this->ok([
            'originals' => $originals->map(fn ($s) => $this->shape($s))->values(),
            'stories' => $stories->map(fn ($s) => $this->shape($s))->values(),
            'total' => $total,
        ]);
    }

    // GET /search/tags?category= : tag yang tersedia di kategori itu
    public function tags(Request $r)
    {
        $tags = Story::where('genre', (string) $r->query('category', ''))
            ->get(['tags'])
            ->pluck('tags')
            ->flatten()
            ->filter()
            ->unique()
            ->sort()
            ->values();

        return $this->ok($tags);
    }

    // GET /search/trending : judul cerita terpopuler sebagai kata kunci
    public function trending()
    {
        $rows = $this->base()->orderByDesc('reads_total')->limit(7)->get();

        return $this->ok($rows->pluck('title')->map(fn ($t) => mb_strtolower($t))->values());
    }

    // GET /genres (tetap ada supaya route lama tidak patah)
    public function genres()
    {
        $rows = Story::query()
            ->whereNotNull('genre')
            ->select('genre', DB::raw('count(*) as total'))
            ->groupBy('genre')
            ->orderByDesc('total')
            ->get();

        return $this->ok($rows->map(fn ($g) => [
            'genre' => $g->genre,
            'total' => (int) $g->total,
        ])->values());
    }
}