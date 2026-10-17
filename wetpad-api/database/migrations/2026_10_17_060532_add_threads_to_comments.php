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
            $t->foreignId('parent_id')->nullable()->after('part_id')
            ->constrained('comments')->cascadeOnDelete();
        });

        Schema::create('comment_likes', function (Blueprint $t) {
            $t->foreignId('user_id')->constrained()->cascadeOnDelete();
            $t->foreignId('comment_id')->constrained()->cascadeOnDelete();
            $t->primary(['user_id', 'comment_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('comment_likes');
        Schema::table('comments', function (Blueprint $t) {
            $t->dropConstrainedForeignId('parent_id');
        });
    }
};
