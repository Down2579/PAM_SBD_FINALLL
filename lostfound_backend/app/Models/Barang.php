<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Barang extends Model
{
    protected $table = 'barang';
    protected $fillable = [
        'nama_barang','deskripsi','gambar_url','tipe_laporan','status','status_verifikasi','tanggal_kejadian',
        'id_pelapor','id_kategori','id_lokasi'
    ];

    public function pelapor(){ return $this->belongsTo(User::class,'id_pelapor'); }
    public function kategori(){ return $this->belongsTo(Kategori::class,'id_kategori'); }
    public function lokasi(){ return $this->belongsTo(Lokasi::class,'id_lokasi'); }
    public function foto(){ return $this->hasMany(FotoBarang::class,'id_barang'); }
    public function pengambilan(){ return $this->hasMany(Pengambilan::class,'id_barang'); }
    public function bukti(){ return $this->hasMany(BuktiPengambilan::class,'id_barang'); }
}
