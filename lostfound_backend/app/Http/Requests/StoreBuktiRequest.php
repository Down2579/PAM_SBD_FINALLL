<?php
namespace App\Http\Requests;
use Illuminate\Foundation\Http\FormRequest;

class StoreBuktiRequest extends FormRequest
{
    public function authorize(){ return auth()->check() && auth()->user()->role === 'admin'; }
    public function rules(){
        return [
            'id_barang'=>'required|integer|exists:barang,id',
            'foto_bukti'=>'required|image|max:5120',
            'catatan'=>'nullable|string'
        ];
    }
}
