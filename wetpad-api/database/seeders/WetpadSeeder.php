<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\{User, Story, Part};
use Illuminate\Support\Facades\Hash;

class WetpadSeeder extends Seeder
{
    public function run(): void
    {
        $author = User::create([
            'username' => 'penulis1', 'email' => 'penulis@wetpad.test',
            'password' => Hash::make('password'),
        ]);
        User::create([
            'username' => 'aji', 'email' => 'aji@wetpad.test',
            'password' => Hash::make('password'),
        ]);

        $stories = [
            ['Senja di Surabaya', 'Romance', ['romance', 'indonesia']],
            ['Kode Merah', 'Thriller', ['thriller', 'hacker']],
            ['Putri Kerajaan Laut', 'Fantasy', ['fantasy', 'petualangan']],
        ];

        foreach ($stories as [$title, $genre, $tags]) {
            $s = Story::create([
                'author_id' => $author->id,
                'title' => $title,
                'description' => "Deskripsi singkat untuk $title.",
                'cover_url' => 'https://picsum.photos/seed/' . urlencode($title) . '/300/450',
                'genre' => $genre,
                'tags' => $tags,
            ]);

            foreach (range(1, 6) as $n) {
                Part::create([
                    'story_id' => $s->id,
                    'part_number' => $n,
                    'title' => "Bab $n",
                    'content' => str_repeat("Ini isi bab $n dari $title. Lorem ipsum dolor sit amet, consectetur adipiscing elit.\n\n", 15),
                    'reads_count' => rand(100, 5000),
                ]);
            }
        }
    }
}
