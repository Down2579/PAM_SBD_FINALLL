<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class FotoBarang extends Model
{
    protected $table = 'foto_barang';
    protected $fillable = ['id_barang', 'url_foto'];

    public function barang()
    {
        return $this->belongsTo(Barang::class, 'id_barang');
    }
}

