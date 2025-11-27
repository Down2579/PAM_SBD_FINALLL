<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateLokasiRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'nama_lokasi' => 'required|string|max:100|unique:lokasi,nama_lokasi,' . $this->lokasi->id,
            'deskripsi' => 'nullable|string'
        ];
    }
}
