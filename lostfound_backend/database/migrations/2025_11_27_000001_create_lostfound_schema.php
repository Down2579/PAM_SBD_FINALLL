<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateLostfoundSchema extends Migration
{
    public function up()
    {
        // USERS
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

        // KATEGORI
        Schema::create('kategori', function (Blueprint $table) {
            $table->id();
            $table->string('nama_kategori',50)->unique();
            $table->text('deskripsi')->nullable();
            $table->timestamps();
        });

        // LOKASI
        Schema::create('lokasi', function (Blueprint $table) {
            $table->id();
            $table->string('nama_lokasi',100)->unique();
            $table->text('deskripsi')->nullable();
            $table->timestamps();
        });

        // BARANG (Laporan hilang/ditemukan)
        Schema::create('barang', function (Blueprint $table) {
            $table->id();
            $table->string('nama_barang',100);
            $table->text('deskripsi');
            $table->string('gambar_url')->nullable();

            $table->enum('tipe_laporan', ['hilang','ditemukan']);
            $table->enum('status', ['pending', 'open','proses_klaim','selesai'])->default('open');

            $table->enum('status_verifikasi', [
                'belum_diverifikasi',
                'menunggu_pemilik',
                'diterima_pemilik',
                'ditolak_pemilik'
            ])->default('belum_diverifikasi');

            $table->date('tanggal_kejadian')->nullable();

            $table->foreignId('id_pelapor')->constrained('users')->onDelete('cascade');
            $table->foreignId('id_kategori')->constrained('kategori')->onDelete('restrict');
            $table->foreignId('id_lokasi')->nullable()->constrained('lokasi')->onDelete('set null');

            $table->timestampsTz();
        });

        // KLAIM PENEMU (FORM PENEMU BARU)
        Schema::create('klaim_penemuan', function (Blueprint $table) {
            $table->id();
            $table->foreignId('id_barang')->constrained('barang')->onDelete('cascade');
            $table->foreignId('id_penemu')->constrained('users')->onDelete('cascade');

            $table->string('lokasi_ditemukan',150);
            $table->text('deskripsi_penemuan')->nullable();
            $table->string('foto_penemuan')->nullable();

            $table->enum('status_klaim', [
                'menunggu_verifikasi_pemilik',
                'diterima_pemilik',
                'ditolak_pemilik',
                'divalidasi_admin',
                'ditolak_admin'
            ])->default('menunggu_verifikasi_pemilik');

            $table->timestampsTz();
        });

        // FOTO BARANG
        Schema::create('foto_barang', function (Blueprint $table) {
            $table->id();
            $table->foreignId('id_barang')->constrained('barang')->onDelete('cascade');
            $table->string('url_foto');
            $table->timestampsTz();
        });

        // BUKTI PENGAMBILAN
        Schema::create('bukti_pengambilan', function (Blueprint $table) {
            $table->id();
            $table->foreignId('id_barang')->constrained('barang')->onDelete('cascade');
            $table->foreignId('id_admin')->constrained('users')->onDelete('cascade');
            $table->string('foto_bukti');
            $table->text('catatan')->nullable();
            $table->timestampTz('tanggal_pengambilan')->useCurrent();
            $table->timestampsTz();
        });

        // NOTIFIKASI
        Schema::create('notifikasi', function (Blueprint $table) {
            $table->id();
            $table->foreignId('id_pengguna')->constrained('users')->onDelete('cascade');
            $table->string('judul',150);
            $table->text('pesan');
            $table->boolean('sudah_dibaca')->default(false);
            $table->timestampTz('created_at')->useCurrent();
        });

        // ACTIVITY LOGS
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
        Schema::dropIfExists('klaim_penemuan');
        Schema::dropIfExists('barang');
        Schema::dropIfExists('lokasi');
        Schema::dropIfExists('kategori');
        Schema::dropIfExists('users');
    }
}
