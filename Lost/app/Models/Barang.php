<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Barang extends Model
{
    protected $table = 'barang';

    protected $fillable = [
        'nama_barang', 'deskripsi', 'gambar_url', 'tipe_laporan',
        'status', 'tanggal_kejadian', 'id_pelapor',
        'id_kategori', 'id_lokasi'
    ];

    public function pelapor()
    {
        return $this->belongsTo(User::class, 'id_pelapor');
    }

    public function kategori()
    {
        return $this->belongsTo(Kategori::class, 'id_kategori');
    }

    public function lokasi()
    {
        return $this->belongsTo(Lokasi::class, 'id_lokasi');
    }

    public function klaim()
    {
        return $this->hasMany(Klaim::class, 'id_barang');
    }
}
