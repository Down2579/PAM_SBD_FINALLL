<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class BuktiPengambilan extends Model
{
    protected $table = 'bukti_pengambilan';
    protected $fillable = [
        'id_barang', 'id_admin', 'foto_bukti', 'catatan'
    ];

    public function barang()
    {
        return $this->belongsTo(Barang::class, 'id_barang');
    }
}

