<?php
namespace App\Http\Requests;
use Illuminate\Foundation\Http\FormRequest;

class StoreBarangRequest extends FormRequest
{
    public function authorize(){ return auth()->check(); }
    public function rules(){
        return [
            'nama_barang'=>'required|string|max:100',
            'deskripsi'=>'required|string',
            'tipe_laporan'=>'required|in:hilang,ditemukan',
            'id_kategori'=>'required|integer|exists:kategori,id',
            'id_lokasi'=>'nullable|integer|exists:lokasi,id',
            'tanggal_kejadian'=>'nullable|date',
            'gambar'=>'nullable|image|max:5120', // max 5MB
            'foto_lain.*'=>'nullable|image|max:5120'
        ];
    }
}
