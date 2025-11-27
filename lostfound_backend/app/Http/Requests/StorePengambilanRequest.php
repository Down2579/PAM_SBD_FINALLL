<?php
namespace App\Http\Requests;
use Illuminate\Foundation\Http\FormRequest;

class StorePengambilanRequest extends FormRequest
{
    public function authorize(){ return auth()->check(); }
    public function rules(){
        return [
            'id_barang'=>'required|integer|exists:barang,id',
            'pesan_pengambilan'=>'required|string'
        ];
    }
}
