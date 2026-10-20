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
        Schema::table('library', function (Blueprint $t) {
            $t->timestamp('added_at')->useCurrent();
            $t->timestamp('last_read_at')->nullable();
            $t->boolean('offline')->default(false);
        });

        Schema::table('reading_lists', function (Blueprint $t) {
            $t->string('uid', 64)->nullable()->after('user_id'); // id buatan aplikasi
            $t->boolean('is_public')->default(true)->after('name');
            $t->unique(['user_id', 'uid']);
        });
    }

    public function down(): void
    {
        Schema::table('reading_lists', function (Blueprint $t) {
            $t->dropUnique(['user_id', 'uid']);
            $t->dropColumn(['uid', 'is_public']);
        });
        Schema::table('library', function (Blueprint $t) {
            $t->dropColumn(['added_at', 'last_read_at', 'offline']);
        });
    }
};
