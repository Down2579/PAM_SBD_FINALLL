<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateKategoriRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'nama_kategori' => 'required|string|max:50|unique:kategori,nama_kategori,' . $this->kategori->id,
            'deskripsi' => 'nullable|string'
        ];
    }
}
