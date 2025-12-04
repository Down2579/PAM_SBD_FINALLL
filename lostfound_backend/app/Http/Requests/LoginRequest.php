<?php
namespace App\Http\Requests;
use Illuminate\Foundation\Http\FormRequest;

class LoginRequest extends FormRequest
{
    public function authorize(){ return true; }
    public function rules(){
        return [
            'email' => 'required_without:nim|email',
            'nim' => 'required_without:email|string',
            'password' => 'required|string'
        ];
    }
}
