<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;

class KlaimPenemuan extends Model
{
    use HasFactory;

    protected $table = 'klaim_penemuan';

    protected $fillable = [
        'id_barang',
        'id_penemu', // User yang mengajukan klaim
        'lokasi_ditemukan',
        'deskripsi_penemuan',
        'foto_penemuan',
        'status_klaim', // 'menunggu_verifikasi_pemilik', 'diterima_pemilik', dll
    ];

    // Agar atribut url lengkap foto_penemuan muncul otomatis di JSON
    protected $appends = ['foto_penemuan_url'];

    // Eager Load relasi agar data user dan barang langsung terbawa
    protected $with = ['penemu', 'barang'];

    // --- RELASI ---

    // Relasi ke User yang melakukan klaim
    public function penemu()
    {
        return $this->belongsTo(User::class, 'id_penemu');
    }

    // Relasi ke Barang yang diklaim
    public function barang()
    {
        return $this->belongsTo(Barang::class, 'id_barang');
    }

    // --- ACCESSOR (Untuk URL Gambar Lengkap) ---

    public function getFotoPenemuanUrlAttribute()
    {
        if ($this->foto_penemuan) {
            return url($this->foto_penemuan);
        }
        return null;
    }
}
