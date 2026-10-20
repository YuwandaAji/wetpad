<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $t) {
            $t->text('about')->nullable();
        });

        Schema::create('follows', function (Blueprint $t) {
            $t->foreignId('follower_id')->constrained('users')->cascadeOnDelete();
            $t->foreignId('followed_id')->constrained('users')->cascadeOnDelete();
            $t->timestamps();
            $t->primary(['follower_id', 'followed_id']);
        });

        Schema::create('profile_posts', function (Blueprint $t) {
            $t->id();
            $t->foreignId('profile_id')->constrained('users')->cascadeOnDelete();
            $t->foreignId('author_id')->constrained('users')->cascadeOnDelete();
            $t->foreignId('parent_id')->nullable()->constrained('profile_posts')->cascadeOnDelete();
            $t->text('body');
            $t->timestamps();
            $t->index(['profile_id', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('profile_posts');
        Schema::dropIfExists('follows');
        Schema::table('users', fn (Blueprint $t) => $t->dropColumn('about'));
    }
};