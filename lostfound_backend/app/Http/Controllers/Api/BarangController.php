<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreBarangRequest; // Pastikan Request ini ada/dibuat
use App\Http\Resources\BarangResource;    // Pastikan Resource ini ada/dibuat
use App\Models\Barang;
use App\Models\FotoBarang;
use App\Models\KlaimPenemuan;
use App\Models\BuktiPengambilan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class BarangController extends Controller
{
    // 1. INDEX: Menampilkan daftar barang (Filter Admin vs User)
    public function index(Request $req)
    {
        $user = auth()->user();
        $q = Barang::with(['pelapor', 'kategori', 'lokasi', 'foto']);

        // Filter Tipe Laporan (hilang/ditemukan)
        if ($req->filled('tipe')) $q->where('tipe_laporan', $req->tipe);

        // Filter Pencarian Nama Barang
        if ($req->filled('q')) $q->where('nama_barang', 'ilike', '%' . $req->q . '%');

        // LOGIC STATUS & HAK AKSES
        if ($user->role === 'admin') {
            // ADMIN:
            if ($req->filled('status')) {
                $q->where('status', $req->status);
            } else {
                // Admin melihat semua, tapi 'pending' diprioritaskan di atas
                $q->orderByRaw("CASE WHEN status = 'pending' THEN 1 ELSE 2 END");
            }
        } else {
            // USER BIASA:
            // 1. Melihat barang yang 'open' (tayang)
            // 2. ATAU melihat barang miliknya sendiri (walau pending/proses)
            $q->where(function ($query) use ($user) {
                $query->where('status', 'open')
                      ->orWhere('id_pelapor', $user->id);
            });

            if ($req->filled('status')) {
                $q->where('status', $req->status);
            }
        }

        return BarangResource::collection($q->orderBy('created_at', 'desc')->paginate(12));
    }

    // 2. STORE: Membuat laporan baru
    public function store(StoreBarangRequest $req)
    {
        $data = $req->validated();
        $user = auth()->user();
        $data['id_pelapor'] = $user->id;

        // LOGIC STATUS AWAL
        // Admin upload -> langsung 'open'
        // User upload -> 'pending' (tunggu verifikasi admin)
        $initialStatus = ($user->role === 'admin') ? 'open' : 'pending';

        $data['status'] = $initialStatus;
        $data['status_verifikasi'] = 'belum_diverifikasi'; // Default database

        // Upload Gambar Utama
        if ($req->hasFile('gambar')) {
            $path = $req->file('gambar')->store('barang', 'public');
            $data['gambar_url'] = '/storage/' . $path;
        }

        $barang = Barang::create($data);

        // Upload Foto Tambahan (foto_lain[])
        if ($req->hasFile('foto_lain')) {
            foreach ($req->file('foto_lain') as $file) {
                $p = $file->store('barang', 'public');
                FotoBarang::create(['id_barang' => $barang->id, 'url_foto' => '/storage/' . $p]);
            }
        }

        return response()->json([
            'message' => $initialStatus == 'pending'
                ? 'Laporan berhasil dibuat. Menunggu verifikasi admin untuk ditayangkan.'
                : 'Laporan berhasil dipublikasikan.',
            'data' => new BarangResource($barang->load(['pelapor', 'kategori', 'lokasi', 'foto']))
        ], 201);
    }

    // 3. SHOW: Detail Barang
    public function show(Barang $barang)
    {
        return new BarangResource($barang->load(['pelapor', 'kategori', 'lokasi', 'foto']));
    }

    // 4. VERIFIKASI: Admin menyetujui barang pending -> open
    public function verifikasi($id)
    {
        $user = auth()->user();

        if ($user->role !== 'admin') {
            return response()->json(['message' => 'Unauthorized. Hanya admin yang bisa verifikasi.'], 403);
        }

        $barang = Barang::findOrFail($id);

        if ($barang->status !== 'pending') {
            return response()->json(['message' => 'Barang sudah diverifikasi atau sedang diproses.'], 400);
        }

        // Update status menjadi OPEN agar muncul di publik
        // Reset status_verifikasi ke default (jaga-jaga)
        $barang->update([
            'status' => 'open',
            'status_verifikasi' => 'belum_diverifikasi'
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Barang berhasil diverifikasi dan tayang ke publik.',
            'data' => new BarangResource($barang)
        ]);
    }

    // 5. UPDATE: Edit Barang
    public function update(StoreBarangRequest $req, Barang $barang)
    {
        $this->authorize('update', $barang); // Pastikan ada Policy atau logic manual
        $data = $req->validated();

        if ($req->hasFile('gambar')) {
            if ($barang->gambar_url) {
                $oldPath = str_replace('/storage/', '', $barang->gambar_url);
                if (Storage::disk('public')->exists($oldPath)) {
                    Storage::disk('public')->delete($oldPath);
                }
            }
            $path = $req->file('gambar')->store('barang', 'public');
            $data['gambar_url'] = '/storage/' . $path;
        }

        $barang->update($data);
        return new BarangResource($barang->fresh());
    }

    // 6. DESTROY: Hapus Barang (Bersih-bersih relasi)
    public function destroy($id)
    {
        $barang = Barang::find($id);

        if (!$barang) {
            return response()->json(['message' => 'Barang tidak ditemukan'], 404);
        }

        $user = auth()->user();

        // Cek Hak Akses (Admin ATAU Pemilik)
        if ($user->role !== 'admin' && $user->id !== $barang->id_pelapor) {
            return response()->json(['message' => 'Anda tidak memiliki izin menghapus barang ini'], 403);
        }

        try {
            // A. Hapus Foto Utama Fisik
            if ($barang->gambar_url) {
                $oldPath = str_replace('/storage/', '', $barang->gambar_url);
                if (Storage::disk('public')->exists($oldPath)) {
                    Storage::disk('public')->delete($oldPath);
                }
            }

            // B. Hapus Foto Tambahan Fisik
            $fotoLain = FotoBarang::where('id_barang', $barang->id)->get();
            foreach ($fotoLain as $foto) {
                if ($foto->url_foto) {
                    $path = str_replace('/storage/', '', $foto->url_foto);
                    if (Storage::disk('public')->exists($path)) {
                        Storage::disk('public')->delete($path);
                    }
                }
                $foto->delete(); // Record DB akan terhapus cascade, tapi file fisik perlu manual
            }

            // Record DB lain (Klaim, Bukti, Notif) biasanya ON DELETE CASCADE di migration,
            // tapi kita hapus manual jika perlu memastikan
            KlaimPenemuan::where('id_barang', $barang->id)->delete();
            BuktiPengambilan::where('id_barang', $barang->id)->delete();

            // Akhirnya Hapus Barang
            $barang->delete();

            return response()->json([
                'success' => true,
                'message' => 'Barang berhasil dihapus'
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal menghapus: ' . $e->getMessage()
            ], 500);
        }
    }
}
