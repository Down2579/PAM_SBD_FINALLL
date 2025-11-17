<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('klaim', function (Blueprint $table) {

            $table->id();

            $table->unsignedBigInteger('id_barang');
            $table->unsignedBigInteger('id_pengklaim');

            $table->text('pesan_klaim');

            $table->enum('status_klaim', ['pending', 'disetujui', 'ditolak'])
                  ->default('pending');

            $table->timestampTz('tanggal_klaim')->useCurrent();

            // Foreign keys
            $table->foreign('id_barang')
                  ->references('id')->on('barang')
                  ->onDelete('cascade');

            $table->foreign('id_pengklaim')
                  ->references('id')->on('users');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('klaim');
    }
};
