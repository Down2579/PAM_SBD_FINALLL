<?php
namespace App\Http\Requests;
use Illuminate\Foundation\Http\FormRequest;

class RegisterRequest extends FormRequest
{
    public function authorize(){ return true; }
    public function rules(){
        return [
            'nama_lengkap'=>'required|string|max:100',
            'nim'=>'required|string|unique:users,nim',
            'email'=>'required|email|unique:users,email',
            'password'=>'required|string|min:6'
        ];
    }
}
