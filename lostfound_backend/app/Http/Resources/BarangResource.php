<?php
namespace App\Http\Resources;
use Illuminate\Http\Resources\Json\JsonResource;

class BarangResource extends JsonResource
{
    public function toArray($request)
    {
        return [
            'id'=>$this->id,
            'nama_barang'=>$this->nama_barang,
            'deskripsi'=>$this->deskripsi,
            'gambar_url'=>$this->gambar_url ? url($this->gambar_url) : null,
            'tipe_laporan'=>$this->tipe_laporan,
            'status'=>$this->status,
            'tanggal_kejadian'=>$this->tanggal_kejadian,
            'pelapor'=> $this->whenLoaded('pelapor', function(){ return [
                'id'=>$this->pelapor->id,'nama_lengkap'=>$this->pelapor->nama_lengkap,'email'=>$this->pelapor->email
            ];}),
            'kategori'=> $this->whenLoaded('kategori', function(){ return $this->kategori?->nama_kategori; }),
            'lokasi'=> $this->whenLoaded('lokasi', function(){ return $this->lokasi?->nama_lokasi; }),
            'foto'=> $this->whenLoaded('foto', function(){ return $this->foto->map(fn($f)=>['id'=>$f->id,'url'=>url($f->url_foto)]); }),
            'created_at'=>$this->created_at,
            'updated_at'=>$this->updated_at,
        ];
    }
}
