<?php

namespace Database\Seeders;

use App\Models\{Part, Story, User};
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class HomeDemoSeeder extends Seeder
{
    public function run(): void
    {
        // samakan genre lama dengan label di halaman pilih genre
        Story::where('genre', 'Romance')->update(['genre' => 'Romansa']);
        Story::where('genre', 'Fantasy')->update(['genre' => 'Fantasi']);

        $author = User::firstOrCreate(
            ['username' => 'penulis1'],
            ['email' => 'penulis@wetpad.test', 'password' => Hash::make('password')]
        );

        $data = [
            ['Orbit Terakhir', 'Fiksi Ilmiah'], ['Kota di Bawah Laut', 'Fiksi Ilmiah'],
            ['Protokol Nol', 'Fiksi Ilmiah'], ['Bintang yang Hilang', 'Fiksi Ilmiah'],
            ['Koloni Merah', 'Fiksi Ilmiah'],
            ['Senandung Pagi', 'Romansa'], ['Surat untuk Rana', 'Romansa'],
            ['Hujan di Bulan Juni', 'Romansa'], ['Kopi dan Kamu', 'Romansa'],
            ['Pedang Naga Biru', 'Fantasi'], ['Penjaga Hutan Kelam', 'Fantasi'],
            ['Kerajaan di Atas Awan', 'Fantasi'],
            ['Jejak di Lorong Gelap', 'Misteri'], ['Rumah No. 13', 'Misteri'],
            ['Saksi Terakhir', 'Thriller'], ['Zona Merah', 'Thriller'],
            ['Kelas 12 IPA 3', 'Fiksi Remaja'], ['Tawa di Ujung Sore', 'Humor'],
            ['Petualangan Si Kancil Modern', 'Petualangan'], ['Bisikan dari Loteng', 'Horor'],
        ];

        $paras = [
            'Pagi itu terasa berbeda dari hari-hari sebelumnya, seolah ada sesuatu yang menunggu di ujung jalan.',
            'Ia menarik napas panjang, lalu melangkah maju tanpa menoleh ke belakang.',
            '"Kamu yakin ingin melakukannya?" tanya suara itu pelan.',
            'Tidak ada jawaban selain angin yang berdesir di antara dedaunan.',
            'Semua yang ia kira benar ternyata hanya separuh dari cerita yang sesungguhnya.',
            'Di kejauhan, cahaya kecil berkedip, seperti memanggilnya untuk datang lebih dekat.',
        ];

        foreach ($data as [$title, $genre]) {
            $s = Story::firstOrCreate(
                ['title' => $title],
                [
                    'author_id' => $author->id,
                    'description' => "Sebuah kisah bergenre $genre tentang pilihan, keberanian, dan hal-hal yang tak terduga.",
                    'cover_url' => 'https://picsum.photos/seed/' . urlencode($title) . '/300/450',
                    'genre' => $genre,
                    'tags' => [strtolower($genre), 'wetpad'],
                    'status' => rand(0, 3) === 0 ? 'completed' : 'ongoing',
                ]
            );

            if (!$s->wasRecentlyCreated) {
                continue;
            }

            foreach (range(1, 6) as $n) {
                $content = collect(range(1, 12))->map(fn () => $paras[array_rand($paras)])->implode("\n\n");
                Part::create([
                    'story_id' => $s->id,
                    'part_number' => $n,
                    'title' => "Bab $n",
                    'content' => $content,
                    'reads_count' => rand(50, 9000),
                ]);
            }
        }
    }
}