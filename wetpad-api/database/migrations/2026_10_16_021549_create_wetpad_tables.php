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
        Schema::create('stories', function (Blueprint $t) {
            $t->id();
            $t->foreignId('author_id')->constrained('users');
            $t->string('title', 200);
            $t->text('description')->nullable();
            $t->text('cover_url')->nullable();
            $t->string('genre', 50)->nullable();
            $t->json('tags')->nullable();
            $t->string('status', 20)->default('ongoing');
            $t->timestamps();
        });

        Schema::create('parts', function (Blueprint $t) {
            $t->id();
            $t->foreignId('story_id')->constrained()->cascadeOnDelete();
            $t->unsignedInteger('part_number');
            $t->string('title', 200);
            $t->longText('content');
            $t->unsignedInteger('reads_count')->default(0);
            $t->timestamps();
            $t->unique(['story_id', 'part_number']);
        });

        Schema::create('votes', function (Blueprint $t) {
            $t->foreignId('user_id')->constrained()->cascadeOnDelete();
            $t->foreignId('part_id')->constrained()->cascadeOnDelete();
            $t->primary(['user_id', 'part_id']);
        });

        Schema::create('comments', function (Blueprint $t) {
            $t->id();
            $t->foreignId('part_id')->constrained()->cascadeOnDelete();
            $t->foreignId('user_id')->constrained()->cascadeOnDelete();
            $t->text('body');
            $t->timestamps();
        });

        Schema::create('library', function (Blueprint $t) {
            $t->foreignId('user_id')->constrained()->cascadeOnDelete();
            $t->foreignId('story_id')->constrained()->cascadeOnDelete();
            $t->foreignId('last_part_id')->nullable()->constrained('parts');
            $t->boolean('archived')->default(false);
            $t->primary(['user_id', 'story_id']);
        });

        Schema::create('reading_lists', function (Blueprint $t) {
            $t->id();
            $t->foreignId('user_id')->constrained()->cascadeOnDelete();
            $t->string('name', 100);
            $t->timestamps();
        });

        Schema::create('reading_list_items', function (Blueprint $t) {
            $t->foreignId('list_id')->constrained('reading_lists')->cascadeOnDelete();
            $t->foreignId('story_id')->constrained()->cascadeOnDelete();
            $t->primary(['list_id', 'story_id']);
        });
    }

        /**
     * Reverse the migrations.
     */

    public function down(): void
    {
        foreach (['reading_list_items','reading_lists','library','comments','votes','parts','stories'] as $tb) {
            Schema::dropIfExists($tb);
        }
    }

};
