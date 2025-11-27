<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Pengambilan extends Model
{
    protected $table = 'pengambilan';
    protected $fillable = ['id_barang','id_pengambil','pesan_pengambilan','status_pengambilan'];

    public function barang(){ return $this->belongsTo(Barang::class,'id_barang'); }
    public function pengambil(){ return $this->belongsTo(User::class,'id_pengambil'); }
}
