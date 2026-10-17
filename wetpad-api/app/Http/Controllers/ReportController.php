<?php

namespace App\Http\Controllers;

use App\Models\{Report, Story};
use Illuminate\Http\Request;

class ReportController extends Controller
{
    public function store(Request $r, $id)
    {
        $v = $r->validate([
            'reason' => 'required|string|max:200',
            'detail' => 'nullable|string|max:2000',
        ]);
        Story::findOrFail($id);
        $rep = Report::create($v + ['user_id' => $r->user()->id, 'story_id' => $id]);
        return $this->ok($rep, 'Laporan terkirim', 201);
    }
}