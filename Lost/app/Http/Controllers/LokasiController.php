<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Lokasi;

class LokasiController extends Controller
{
    public function index()
    {
        return Lokasi::all();
    }

    public function store(Request $request)
    {
        $request->validate([
            'nama_lokasi' => 'required|string|max:255'
        ]);

        $lokasi = Lokasi::create([
            'nama_lokasi' => $request->nama_lokasi
        ]);

        return response()->json([
            'message' => 'Lokasi berhasil dibuat',
            'data' => $lokasi
        ], 201);
    }
}
