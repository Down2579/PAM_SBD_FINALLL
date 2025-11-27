<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Klaim extends Model
{
    protected $table = 'pengambilan';

    protected $fillable = [
        'id_barang', 'id_pengklaim', 'pesan_klaim', 'status_klaim'
    ];

    public function barang()
    {
        return $this->belongsTo(Barang::class, 'id_barang');
    }

    public function pengklaim()
    {
        return $this->belongsTo(User::class, 'id_pengklaim');
    }
}

