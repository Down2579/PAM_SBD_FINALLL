<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\BuktiPengambilan;
use App\Models\Barang;
use App\Models\ActivityLog;
use App\Models\Notifikasi;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\DB;

class BuktiPengambilanController extends Controller
{
    // Tampilkan bukti pengambilan untuk sebuah barang (jika ada)
    public function show($id_barang)
    {
        $bukti = BuktiPengambilan::where('id_barang', $id_barang)->latest()->first();
        return response()->json($bukti);
    }

    // Simpan bukti pengambilan (admin yang melakukan)
    public function store(Request $request, $id_barang)
    {
        $request->validate([
            'foto_bukti' => 'required|image|max:5120',
            'catatan' => 'nullable|string',
        ]);

        $file = $request->file('foto_bukti');
        $path = $file->store('bukti_pengambilan', 'public');

        // gunakan transaksi agar konsisten: insert bukti, update status barang, buat notifikasi, log
        DB::beginTransaction();
        try {
            $bukti = BuktiPengambilan::create([
                'id_barang' => $id_barang,
                'id_admin' => auth()->id(),
                'foto_bukti' => $path,
                'catatan' => $request->input('catatan'),
            ]);

            // Update status barang menjadi 'selesai' (jika ada model Barang)
            $barang = Barang::find($id_barang);
            if ($barang) {
                $barang->status = 'selesai';
                $barang->updated_at = now();
                $barang->save();
            }

            // Buat notifikasi untuk pelapor barang
            if ($barang) {
                Notifikasi::create([
                    'id_pengguna' => $barang->id_pelapor,
                    'judul' => 'Barang Telah Diambil',
                    'pesan' => 'Barang Anda (ID: '.$id_barang.') telah diambil dan proses selesai.'
                ]);
            }

            // Log aktivitas
            ActivityLog::create([
                'id_pengguna' => auth()->id(),
                'aktivitas' => "Upload bukti pengambilan untuk barang id: {$id_barang}",
                'metadata' => json_encode(['bukti_id' => $bukti->id, 'path' => $path])
            ]);

            DB::commit();
            return response()->json($bukti, 201);
        } catch (\Throwable $e) {
            DB::rollBack();
            // hapus file jika terjadi error
            if (Storage::disk('public')->exists($path)) {
                Storage::disk('public')->delete($path);
            }
            return response()->json(['message' => 'Gagal menyimpan bukti pengambilan.', 'error' => $e->getMessage()], 500);
        }
    }
}
