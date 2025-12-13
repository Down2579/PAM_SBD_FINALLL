<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\KlaimPenemuan;
use App\Models\Barang;
use App\Models\Notifikasi;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\DB;

class KlaimPenemuanController extends Controller
{
    // GET List Klaim
    public function index(Request $request)
    {
        $user = auth()->user();

        // PERUBAHAN DISINI: Tambahkan 'with' untuk memuat relasi
        // 'barang.pelapor' artinya: Ambil data Barang, lalu ambil data Pelapor di dalam barang tsb.
        $query = KlaimPenemuan::with(['barang.pelapor', 'barang.kategori', 'barang.lokasi', 'penemu']);

        // Filter berdasarkan barang tertentu (untuk detail page)
        if ($request->has('barang_id')) {
            $query->where('id_barang', $request->barang_id);
        } else {
            // Jika tidak ada filter barang:
            if ($user->role !== 'admin') {
                // User biasa hanya melihat klaim yang diajukan OLEHNYA
                // ATAU klaim YANG MASUK ke barang laporannya
                $query->where('id_penemu', $user->id)
                      ->orWhereHas('barang', function($q) use ($user) {
                          $q->where('id_pelapor', $user->id);
                      });
            }
            // Admin melihat semua (tidak perlu filter tambahan)
        }

        $data = $query->orderBy('created_at', 'desc')->get();

        return response()->json([
            'success' => true,
            'message' => 'Data klaim berhasil diambil',
            'data' => $data
        ]);
    }

    // POST Buat Klaim Baru (User mengklaim barang)
    public function store(Request $request)
    {
        $request->validate([
            'id_barang' => 'required|exists:barang,id',
            'deskripsi_klaim' => 'required|string', // Di flutter kuncinya 'deskripsi_klaim' (sesuai providers)
            'foto_penemuan' => 'nullable|image|max:5120', // Opsional, bukti foto
        ]);

        $barang = Barang::findOrFail($request->id_barang);
        $userId = auth()->id();

        // Validasi: Tidak bisa klaim barang laporan sendiri
        if ($barang->id_pelapor == $userId) {
            return response()->json(['message' => 'Anda tidak bisa mengklaim laporan sendiri'], 422);
        }

        // Cek apakah sudah pernah klaim
        $existing = KlaimPenemuan::where('id_barang', $barang->id)
                    ->where('id_penemu', $userId)
                    ->first();

        if ($existing) {
             return response()->json(['message' => 'Anda sudah mengajukan klaim untuk barang ini'], 422);
        }

        DB::beginTransaction();
        try {
            $path = null;
            if ($request->hasFile('foto_penemuan')) {
                $file = $request->file('foto_penemuan');
                $filename = time() . '_' . $file->getClientOriginalName();
                $filePath = $file->storeAs('klaim_bukti', $filename, 'public');
                $path = '/storage/' . $filePath;
            }

            // Simpan Data Klaim
            $klaim = KlaimPenemuan::create([
                'id_barang' => $barang->id,
                'id_penemu' => $userId,
                'lokasi_ditemukan' => '-', // Default strip jika user tidak input lokasi spesifik
                'deskripsi_penemuan' => $request->deskripsi_klaim, // Mapping input flutter ke db
                'foto_penemuan' => $path,
                'status_klaim' => 'menunggu_verifikasi_pemilik'
            ]);

            // Update status barang jadi 'proses_klaim' agar user lain tau sedang ada proses
            $barang->update(['status' => 'proses_klaim']);

            // Buat Notifikasi ke Pemilik Barang
            Notifikasi::create([
                'id_pengguna' => $barang->id_pelapor,
                'judul' => 'Klaim Baru Masuk',
                'pesan' => 'Seseorang mengklaim barang laporan Anda: ' . $barang->nama_barang,
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Klaim berhasil diajukan',
                'data' => $klaim
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['message' => 'Gagal mengajukan klaim: ' . $e->getMessage()], 500);
        }
    }

    // PATCH Update Status (Terima / Tolak)
    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status_klaim' => 'required|in:diterima_pemilik,ditolak_pemilik,ditolak_admin,divalidasi_admin'
        ]);

        $klaim = KlaimPenemuan::findOrFail($id);
        $barang = Barang::findOrFail($klaim->id_barang);
        $user = auth()->user();

        // Validasi Hak Akses (Hanya pemilik barang atau admin yang boleh ubah status)
        if ($barang->id_pelapor !== $user->id && $user->role !== 'admin') {
            return response()->json(['message' => 'Unauthorized action'], 403);
        }

        $newStatus = $request->status_klaim;
        $klaim->update(['status_klaim' => $newStatus]);

        // Logic Update Status Barang Induk
        if ($newStatus == 'diterima_pemilik') {
            // Jika diterima, barang tetap 'proses_klaim' menunggu pengambilan fisik (upload bukti)
            // Atau bisa langsung 'selesai' tergantung flow bisnis Anda.
            // Di sini kita biarkan 'proses_klaim' sampai ada upload bukti di PengambilanController

            // Notifikasi ke Pengklaim bahwa diterima
            Notifikasi::create([
                'id_pengguna' => $klaim->id_penemu,
                'judul' => 'Klaim Diterima',
                'pesan' => 'Klaim Anda untuk barang ' . $barang->nama_barang . ' telah disetujui. Silakan hubungi pemilik.',
            ]);

        } elseif ($newStatus == 'ditolak_pemilik' || $newStatus == 'ditolak_admin') {
            // Jika ditolak, cek apakah masih ada klaim lain yang pending?
            // Jika tidak ada, kembalikan status barang jadi 'open'
            $pendingClaims = KlaimPenemuan::where('id_barang', $barang->id)
                ->where('status_klaim', 'menunggu_verifikasi_pemilik')
                ->exists();

            if (!$pendingClaims) {
                $barang->update(['status' => 'open']);
            }

            Notifikasi::create([
                'id_pengguna' => $klaim->id_penemu,
                'judul' => 'Klaim Ditolak',
                'pesan' => 'Maaf, klaim Anda untuk barang ' . $barang->nama_barang . ' ditolak.',
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Status klaim diperbarui',
            'data' => $klaim
        ]);
    }
}
