<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Part extends Model {
    protected $fillable = ['story_id','part_number','title','content','reads_count'];
    public function story() { return $this->belongsTo(Story::class); }
}