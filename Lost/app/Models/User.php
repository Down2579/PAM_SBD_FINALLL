<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens;

    protected $table = 'users';

    protected $fillable = [
        'nama_lengkap', 'nim', 'email', 'password_hash',
        'nomor_telepon', 'role'
    ];

    protected $hidden = ['password_hash'];

    public function barang()
    {
        return $this->hasMany(Barang::class, 'id_pelapor');
    }

    public function klaim()
    {
        return $this->hasMany(Klaim::class, 'id_pengklaim');
    }
}
