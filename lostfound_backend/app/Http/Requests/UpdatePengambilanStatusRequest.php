<?php
namespace App\Http\Requests;
use Illuminate\Foundation\Http\FormRequest;

class UpdatePengambilanStatusRequest extends FormRequest
{
    public function authorize(){
        return auth()->check() && auth()->user()->role === 'admin';
    }
    public function rules(){
        return ['status_pengambilan'=>'required|in:pending,disetujui,ditolak'];
    }
}
