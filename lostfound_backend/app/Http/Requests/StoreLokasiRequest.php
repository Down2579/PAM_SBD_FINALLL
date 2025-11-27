<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreLokasiRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'nama_lokasi' => 'required|string|max:100|unique:lokasi,nama_lokasi',
            'deskripsi' => 'nullable|string'
        ];
    }
}
