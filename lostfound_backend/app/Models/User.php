<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Notifications\Notifiable;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class User extends Authenticatable
{
    use HasApiTokens, Notifiable, HasFactory;

    protected $fillable = [
        'nama_lengkap','nim','email','password','nomor_telepon','role'
    ];

    protected $hidden = ['password'];

    public function barang() { return $this->hasMany(Barang::class, 'id_pelapor'); }
    public function pengambilan() { return $this->hasMany(Pengambilan::class, 'id_pengambil'); }
    public function notifikasi() { return $this->hasMany(Notifikasi::class, 'id_pengguna'); }
    public function bukti() { return $this->hasMany(BuktiPengambilan::class, 'id_admin'); }
}
