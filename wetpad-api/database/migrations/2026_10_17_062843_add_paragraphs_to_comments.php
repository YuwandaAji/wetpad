<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('comments', function (Blueprint $t) {
            $t->unsignedInteger('paragraph_index')->nullable()->after('parent_id');
        });

        Schema::create('reactions', function (Blueprint $t) {
            $t->foreignId('user_id')->constrained()->cascadeOnDelete();
            $t->foreignId('part_id')->constrained()->cascadeOnDelete();
            $t->unsignedInteger('paragraph_index');
            $t->unsignedTinyInteger('sticker'); // nomor emoji di daftar Flutter (0-23)
            $t->timestamps();
            $t->primary(['user_id', 'part_id', 'paragraph_index']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('reactions');
        Schema::table('comments', fn (Blueprint $t) => $t->dropColumn('paragraph_index'));
    }
};
