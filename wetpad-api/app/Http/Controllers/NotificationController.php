<?php
namespace App\Http\Controllers;

use App\Models\UserNotification;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $r)
    {
        $uid = $r->user()->id;
        $items = UserNotification::where('user_id', $uid)->latest('id')->limit(50)->get();

        return $this->ok([
            'unread_count' => UserNotification::where('user_id', $uid)->whereNull('read_at')->count(),
            'items' => $items->map(fn ($n) => [
                'id' => $n->id,
                'type' => $n->type,
                'title' => $n->title,
                'body' => $n->body,
                'story_id' => $n->story_id,
                'part_id' => $n->part_id,
                'is_read' => $n->read_at !== null,
                'created_at' => $n->created_at->toIso8601String(),
            ]),
        ]);
    }

    public function read(Request $r, $id)
    {
        UserNotification::where('user_id', $r->user()->id)->where('id', $id)
            ->whereNull('read_at')->update(['read_at' => now()]);
        return $this->ok();
    }

    public function readAll(Request $r)
    {
        UserNotification::where('user_id', $r->user()->id)
            ->whereNull('read_at')->update(['read_at' => now()]);
        return $this->ok();
    }
}