<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class BarangController extends Controller
{
    public function index()
    {
        return Barang::with(['pelapor', 'kategori', 'lokasi'])->get();
    }

    public function store(Request $req)
    {
        $req->validate([
            'nama_barang' => 'required',
            'tipe_laporan' => 'required',
            'id_pelapor' => 'required'
        ]);

        $barang = Barang::create($req->all());

        return response()->json($barang);
    }

    public function show($id)
    {
        return Barang::with(['pelapor', 'kategori', 'lokasi', 'klaim'])
            ->findOrFail($id);
    }
}
