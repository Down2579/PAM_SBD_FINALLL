<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateLostfoundSchema extends Migration
{
    public function up()
    {
        // Users
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('nama_lengkap',100);
            $table->string('nim',20)->unique();
            $table->string('email',100)->unique();
            $table->string('password');
            $table->string('nomor_telepon',15)->nullable();
            $table->enum('role',['mahasiswa','admin'])->default('mahasiswa');
            $table->timestampsTz();
        });

        // Kategori
        Schema::create('kategori', function (Blueprint $table) {
            $table->id();
            $table->string('nama_kategori',50)->unique();
            $table->text('deskripsi')->nullable();
            $table->timestamps();
        });

        // Lokasi
        Schema::create('lokasi', function (Blueprint $table) {
            $table->id();
            $table->string('nama_lokasi',100)->unique();
            $table->text('deskripsi')->nullable();
            $table->timestamps();
        });

        // Barang
        Schema::create('barang', function (Blueprint $table) {
            $table->id();
            $table->string('nama_barang',100);
            $table->text('deskripsi');
            $table->string('gambar_url')->nullable();
            $table->enum('tipe_laporan',['hilang','ditemukan']);
            $table->enum('status',['open','proses_klaim','selesai'])->default('open');
            $table->date('tanggal_kejadian')->nullable();

            $table->foreignId('id_pelapor')->constrained('users')->onDelete('cascade');
            $table->foreignId('id_kategori')->constrained('kategori')->onDelete('restrict');
            $table->foreignId('id_lokasi')->nullable()->constrained('lokasi')->onDelete('set null');

            $table->timestampsTz();
        });

        // Pengambilan
        Schema::create('pengambilan', function (Blueprint $table) {
            $table->id();
            $table->foreignId('id_barang')->constrained('barang')->onDelete('cascade');
            $table->foreignId('id_pengambil')->constrained('users')->onDelete('cascade');
            $table->text('pesan_pengambilan');
            $table->enum('status_pengambilan',['pending','disetujui','ditolak'])->default('pending');
            $table->timestampTz('tanggal_pengambilan')->useCurrent();
            $table->timestamps();
        });

        // Foto Barang
        Schema::create('foto_barang', function (Blueprint $table) {
            $table->id();
            $table->foreignId('id_barang')->constrained('barang')->onDelete('cascade');
            $table->string('url_foto');
            $table->timestampsTz();
        });

        // Bukti Pengambilan
        Schema::create('bukti_pengambilan', function (Blueprint $table) {
            $table->id();
            $table->foreignId('id_barang')->constrained('barang')->onDelete('cascade');
            $table->foreignId('id_admin')->constrained('users')->onDelete('cascade');
            $table->string('foto_bukti');
            $table->text('catatan')->nullable();
            $table->timestampTz('tanggal_pengambilan')->useCurrent();
            $table->timestampsTz();
        });

        // Notifikasi
        Schema::create('notifikasi', function (Blueprint $table) {
            $table->id();
            $table->foreignId('id_pengguna')->constrained('users')->onDelete('cascade');
            $table->string('judul',150);
            $table->text('pesan');
            $table->boolean('sudah_dibaca')->default(false);
            $table->timestampTz('created_at')->useCurrent();
        });

        // Activity Logs
        Schema::create('activity_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('id_pengguna')->nullable()->constrained('users')->onDelete('set null');
            $table->text('aktivitas');
            $table->jsonb('metadata')->nullable();
            $table->timestampTz('created_at')->useCurrent();
        });
    }

    public function down()
    {
        Schema::dropIfExists('activity_logs');
        Schema::dropIfExists('notifikasi');
        Schema::dropIfExists('bukti_pengambilan');
        Schema::dropIfExists('foto_barang');
        Schema::dropIfExists('pengambilan');
        Schema::dropIfExists('barang');
        Schema::dropIfExists('lokasi');
        Schema::dropIfExists('kategori');
        Schema::dropIfExists('users');
    }
}
