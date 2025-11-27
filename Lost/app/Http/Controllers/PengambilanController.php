<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Pengambilan;

class PengambilanController extends Controller
{
    public function store(Request $req)
    {
        $req->validate([
            'id_barang' => 'required',
            'id_pengklaim' => 'required',
            'pesan_klaim' => 'required',
        ]);

        $pengambilan = Pengambilan::create($req->all());

        return response()->json($pengambilan);
    }

    public function approve($id)
    {
        $pengambilan = Pengambilan::findOrFail($id);
        $pengambilan->update(['status_klaim' => 'disetujui']);
        return response()->json(['message' => 'Klaim disetujui']);
    }

    public function reject($id)
    {
        $pengambilan = Pengambilan::findOrFail($id);
        $pengambilan->update(['status_klaim' => 'ditolak']);
        return response()->json(['message' => 'Klaim ditolak']);
    }
}
