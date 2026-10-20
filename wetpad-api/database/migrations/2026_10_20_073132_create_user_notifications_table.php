<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
   
    public function up(): void
    {
        Schema::create('user_notifications', function (Blueprint $t) {
       $t->id();
       $t->foreignId('user_id')->constrained()->cascadeOnDelete();
       $t->foreignId('actor_id')->nullable()->constrained('users')->nullOnDelete();
       $t->string('type', 20);
       $t->foreignId('story_id')->nullable()->constrained()->cascadeOnDelete();
       $t->foreignId('part_id')->nullable()->constrained()->cascadeOnDelete();
       $t->string('title', 200);
       $t->string('body', 300)->nullable();
       $t->timestamp('read_at')->nullable();
       $t->timestamps();
       $t->index(['user_id', 'created_at']);
   });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('user_notifications');
    }
};
