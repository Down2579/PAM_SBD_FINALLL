<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class KlaimController extends Controller
{
    public function store(Request $req)
    {
        $req->validate([
            'id_barang' => 'required',
            'id_pengklaim' => 'required',
            'pesan_klaim' => 'required',
        ]);

        $klaim = Klaim::create($req->all());

        return response()->json($klaim);
    }

    public function approve($id)
    {
        $klaim = Klaim::findOrFail($id);
        $klaim->update(['status_klaim' => 'disetujui']);
        return response()->json(['message' => 'Klaim disetujui']);
    }

    public function reject($id)
    {
        $klaim = Klaim::findOrFail($id);
        $klaim->update(['status_klaim' => 'ditolak']);
        return response()->json(['message' => 'Klaim ditolak']);
    }
}
