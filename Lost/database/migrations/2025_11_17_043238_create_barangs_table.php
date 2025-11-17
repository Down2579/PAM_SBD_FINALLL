<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('barang', function (Blueprint $table) {

            $table->id();
            $table->string('nama_barang', 100);
            $table->text('deskripsi');
            $table->string('gambar_url', 255)->nullable();

            // ENUM PostgreSQL
            $table->enum('tipe_laporan', ['hilang', 'ditemukan']);
            $table->enum('status', ['open', 'proses_klaim', 'selesai'])
                  ->default('open');

            $table->date('tanggal_kejadian')->nullable();

            // Foreign keys
            $table->unsignedBigInteger('id_pelapor');
            $table->unsignedBigInteger('id_kategori');
            $table->unsignedBigInteger('id_lokasi')->nullable();

            $table->foreign('id_pelapor')->references('id')->on('users');
            $table->foreign('id_kategori')->references('id')->on('kategori');
            $table->foreign('id_lokasi')->references('id')->on('lokasi');

            $table->timestampTz('created_at')->useCurrent();
            $table->timestampTz('updated_at')->useCurrent();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('barang');
    }
};
