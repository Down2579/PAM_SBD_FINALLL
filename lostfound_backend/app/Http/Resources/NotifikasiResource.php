<?php
namespace App\Http\Resources;
use Illuminate\Http\Resources\Json\JsonResource;

class NotifikasiResource extends JsonResource
{
    public function toArray($request)
    {
        return [
            'id'=>$this->id,
            'judul'=>$this->judul,
            'pesan'=>$this->pesan,
            'sudah_dibaca'=>$this->sudah_dibaca,
            'created_at'=>$this->created_at,
        ];
    }
}
