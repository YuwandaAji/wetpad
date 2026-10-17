<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Story extends Model {
    protected $fillable = ['author_id','title','description','cover_url','genre','tags','status'];
    protected $casts = ['tags' => 'array'];
    public function author() { return $this->belongsTo(User::class, 'author_id'); }
    public function parts()  { return $this->hasMany(Part::class)->orderBy('part_number'); }
}
