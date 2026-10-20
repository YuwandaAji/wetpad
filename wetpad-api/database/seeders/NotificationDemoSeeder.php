<?php

namespace Database\Seeders;

use App\Models\{Story, User, UserNotification};
use Illuminate\Database\Seeder;

class NotificationDemoSeeder extends Seeder
{
    public function run(): void
    {
        $me = User::where('username', 'aji')->first();
        $author = User::where('username', 'penulis1')->first();
        $story = Story::first();

        if (!$me || !$story) {
            $this->command->warn('Butuh user "aji" dan minimal 1 cerita. Jalankan WetpadSeeder dulu.');
            return;
        }
        
        if (UserNotification::where('user_id', $me->id)->exists()) {
            $this->command->info('User "aji" sudah punya notifikasi, dilewati.');
            return;
        }
        
        $rows = [
            ['story_update', $story->title, 'penulis1 memperbarui cerita dengan Bab 6.', $story->id, 25, false],
            ['follow', 'penulis1 mulai mengikuti kamu', 'Lihat profilnya dan ikuti balik.', null, 140, false],
            ['like', 'penulis1 menyukai komentarmu', 'Plot twist di bab terakhir benar-benar gila!', $story->id, 600, true],
            ['comment', 'penulis1 membalas komentarmu', 'Terima kasih sudah membaca!', $story->id, 2900, true],
        ];

        foreach ($rows as [$type, $title, $body, $storyId, $minutesAgo, $read]) {
            UserNotification::forceCreate([
                'user_id' => $me->id,
                'actor_id' => $author?->id,
                'type' => $type,
                'story_id' => $storyId,
                'title' => $title,
                'body' => $body,
                'read_at' => $read ? now() : null,
                'created_at' => now()->subMinutes($minutesAgo),
                'updated_at' => now()->subMinutes($minutesAgo),
            ]);
        }
    }
}