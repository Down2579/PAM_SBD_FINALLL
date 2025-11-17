<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {

            $table->id();
            $table->string('nama_lengkap', 100);
            $table->string('nim', 20)->unique();
            $table->string('email', 100)->unique();
            $table->string('password_hash', 255);
            $table->string('nomor_telepon', 15)->nullable();

            // ENUM PostgreSQL
            $table->enum('role', ['mahasiswa', 'admin'])
                  ->default('mahasiswa');

            $table->timestampTz('created_at')->useCurrent();
            $table->timestampTz('updated_at')->nullable()->useCurrentOnUpdate();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};
