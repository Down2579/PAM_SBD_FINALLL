<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\FotoBarang;
use App\Models\ActivityLog;
use Illuminate\Support\Facades\Storage;

class FotoBarangController extends Controller
{
    // Tampilkan semua foto untuk sebuah barang
    public function index($id_barang)
    {
        $fotos = FotoBarang::where('id_barang', $id_barang)->orderBy('created_at', 'asc')->get();
        return response()->json($fotos);
    }

    // Simpan foto baru untuk barang
    public function store(Request $request, $id_barang)
    {
        $request->validate([
            'photo' => 'required|image|max:5120', // max 5MB
        ]);

        $file = $request->file('photo');
        $path = $file->store('foto_barang', 'public');

        $foto = FotoBarang::create([
            'id_barang' => $id_barang,
            'url_foto' => $path,
        ]);

        // Log aktivitas
        ActivityLog::create([
            'id_pengguna' => auth()->id(),
            'aktivitas' => "Menambah foto untuk barang id: {$id_barang}",
            'metadata' => json_encode(['foto_id' => $foto->id, 'path' => $path])
        ]);

        return response()->json($foto, 201);
    }

    // Hapus foto (by id foto)
    public function destroy($id)
    {
        $foto = FotoBarang::findOrFail($id);

        // Hapus file dari storage jika ada
        if ($foto->url_foto && Storage::disk('public')->exists($foto->url_foto)) {
            Storage::disk('public')->delete($foto->url_foto);
        }

        $foto->delete();

        // Log aktivitas
        ActivityLog::create([
            'id_pengguna' => auth()->id(),
            'aktivitas' => "Menghapus foto id: {$id}",
            'metadata' => json_encode(['foto_id' => $id])
        ]);

        return response()->json(['message' => 'Foto berhasil dihapus.']);
    }
}
