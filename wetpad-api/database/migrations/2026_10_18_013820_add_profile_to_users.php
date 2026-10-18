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
        Schema::table('users', function (Blueprint $t) {
            $t->date('birth_date')->nullable()->after('email');
            $t->string('pronoun', 30)->nullable()->after('birth_date');
            $t->boolean('newsletter')->default(false)->after('pronoun');
            $t->json('genres')->nullable()->after('newsletter');
        });
    }

    public function down(): void
    {
        Schema::table('users', fn (Blueprint $t) => $t->dropColumn(['birth_date', 'pronoun', 'newsletter', 'genres']));
    }
};
