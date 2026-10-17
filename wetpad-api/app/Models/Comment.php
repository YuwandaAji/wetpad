<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Comment extends Model
{
    protected $fillable = ['part_id', 'user_id', 'parent_id', 'paragraph_index', 'body'];

    public function user()    { return $this->belongsTo(User::class); }
    public function part()    { return $this->belongsTo(Part::class); }
    public function replies() { return $this->hasMany(Comment::class, 'parent_id'); }
    public function likedBy() { return $this->belongsToMany(User::class, 'comment_likes', 'comment_id', 'user_id'); }
}