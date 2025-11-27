<?php
namespace App\Http\Resources;
use Illuminate\Http\Resources\Json\JsonResource;

class PengambilanResource extends JsonResource
{
    public function toArray($request)
    {
        return [
            'id'=>$this->id,
            'id_barang'=>$this->id_barang,
            'barang'=>$this->whenLoaded('barang', function(){ return [
                'id'=>$this->barang->id,'nama'=>$this->barang->nama_barang,'status'=>$this->barang->status
            ];}),
            'id_pengambil'=>$this->id_pengambil,
            'pengambil'=>$this->whenLoaded('pengambil', function(){ return ['id'=>$this->pengambil->id,'nama'=>$this->pengambil->nama_lengkap]; }),
            'pesan_pengambilan'=>$this->pesan_pengambilan,
            'status_pengambilan'=>$this->status_pengambilan,
            'tanggal_pengambilan'=>$this->tanggal_pengambilan,
            'created_at'=>$this->created_at,
        ];
    }
}
