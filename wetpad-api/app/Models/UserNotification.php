<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class UserNotification extends Model
{
    protected $fillable = ['user_id','actor_id','type','story_id','part_id','title','body','read_at'];
    protected $casts = ['read_at' => 'datetime'];

    public static function notifyUser(int $to, ?int $actor, string $type, string $title,
        ?string $body = null, ?int $storyId = null, ?int $partId = null): void
    {
        if ($actor !== null && $actor === $to) return; // don't notify yourself
        static::create([
            'user_id' => $to, 'actor_id' => $actor, 'type' => $type,
            'title' => $title, 'body' => $body, 'story_id' => $storyId, 'part_id' => $partId,
        ]);
    }
}