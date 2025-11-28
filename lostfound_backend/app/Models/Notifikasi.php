<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Notifikasi extends Model
{
    protected $table = 'notifikasi';
    public $timestamps = false;
    protected $fillable = ['id_pengguna','judul','pesan','sudah_dibaca','created_at'];
    public function pengguna(){ return $this->belongsTo(User::class,'id_pengguna'); }
}
