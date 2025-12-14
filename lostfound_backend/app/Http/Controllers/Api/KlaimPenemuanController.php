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
    // 1. INDEX: List Klaim
    public function index(Request $request)
    {
        $user = auth()->user();

        // Eager Load data barang & pelapor untuk ditampilkan di frontend
        $query = KlaimPenemuan::with(['barang.pelapor', 'barang.kategori', 'barang.lokasi', 'penemu']);

        // Filter berdasarkan ID Barang (Untuk Detail Page Barang)
        if ($request->has('barang_id')) {
            $query->where('id_barang', $request->barang_id);
        } else {
            // Filter berdasarkan Role User
            if ($user->role !== 'admin') {
                // User biasa melihat:
                // 1. Klaim yang dia ajukan sendiri
                // 2. ATAU Klaim orang lain terhadap barang laporannya
                $query->where('id_penemu', $user->id)
                      ->orWhereHas('barang', function($q) use ($user) {
                          $q->where('id_pelapor', $user->id);
                      });
            }
            // Admin melihat semua
        }

        $data = $query->orderBy('created_at', 'desc')->get();

        return response()->json([
            'success' => true,
            'data' => $data
        ]);
    }

    // 2. STORE: User Mengajukan Klaim
    public function store(Request $request)
    {
        $request->validate([
            'id_barang' => 'required|exists:barang,id',
            'deskripsi_klaim' => 'required|string',
            'foto_penemuan' => 'nullable|image|max:5120',
        ]);

        $barang = Barang::findOrFail($request->id_barang);
        $userId = auth()->id();

        // Validasi: Tidak boleh klaim barang sendiri
        if ($barang->id_pelapor == $userId) {
            return response()->json(['message' => 'Anda tidak bisa mengklaim laporan sendiri'], 422);
        }

        // Validasi: Tidak boleh double claim
        $existing = KlaimPenemuan::where('id_barang', $barang->id)
                    ->where('id_penemu', $userId)
                    ->first();
        if ($existing) {
             return response()->json(['message' => 'Anda sudah mengajukan klaim untuk barang ini'], 422);
        }

        DB::beginTransaction();
        try {
            // Upload Foto Bukti Klaim (jika ada)
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
                'lokasi_ditemukan' => $request->lokasi_ditemukan ?? '-',
                'deskripsi_penemuan' => $request->deskripsi_klaim,
                'foto_penemuan' => $path,
                'status_klaim' => 'menunggu_verifikasi_pemilik'
            ]);

            // SINKRONISASI STATUS BARANG
            // Ubah status barang agar user lain tahu ada proses berjalan
            $barang->update([
                'status' => 'proses_klaim',
                'status_verifikasi' => 'menunggu_pemilik' // Kolom penanda fase klaim
            ]);

            // Notifikasi ke Pemilik Barang
            Notifikasi::create([
                'id_pengguna' => $barang->id_pelapor,
                'judul' => 'Klaim Baru Masuk',
                'pesan' => 'Seseorang mengklaim barang: ' . $barang->nama_barang . '. Cek segera!',
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Klaim berhasil diajukan',
                'data' => $klaim
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['message' => 'Gagal: ' . $e->getMessage()], 500);
        }
    }

    // 3. UPDATE STATUS: Pemilik/Admin Menerima atau Menolak Klaim
    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status_klaim' => 'required|in:diterima_pemilik,ditolak_pemilik,ditolak_admin,divalidasi_admin'
        ]);

        $klaim = KlaimPenemuan::findOrFail($id);
        $barang = Barang::findOrFail($klaim->id_barang);
        $user = auth()->user();

        // 1. Validasi Hak Akses
        if ($barang->id_pelapor !== $user->id && $user->role !== 'admin') {
            return response()->json(['message' => 'Unauthorized action'], 403);
        }

        DB::beginTransaction();
        try {
            $newStatus = $request->status_klaim;

            // --- VALIDASI TAMBAHAN: MENCEGAH DOUBLE ACCEPT ---
            if ($newStatus == 'diterima_pemilik') {
                // Cek apakah SUDAH ADA klaim lain yang diterima untuk barang ini?
                $alreadyAccepted = KlaimPenemuan::where('id_barang', $barang->id)
                    ->where('id', '!=', $id) // Bukan ID klaim yang sedang diproses
                    ->where('status_klaim', 'diterima_pemilik')
                    ->exists();

                if ($alreadyAccepted) {
                    return response()->json([
                        'message' => 'Gagal! Sudah ada klaim lain yang diterima untuk barang ini.'
                    ], 400);
                }
            }
            // --------------------------------------------------

            // 2. Update Status Klaim Ini
            $klaim->update(['status_klaim' => $newStatus]);

            // 3. Logic Sinkronisasi ke Barang
            if ($newStatus == 'diterima_pemilik') {

                // UPDATE BARANG: Paksa update status_verifikasi
                $barang->status = 'proses_klaim';
                $barang->status_verifikasi = 'diterima_pemilik';
                $barang->save(); // Menggunakan save() terkadang lebih aman daripada update() jika ada isu fillable

                // AUTO-REJECT KLAIM LAIN
                // Semua klaim lain yang masih "menunggu" otomatis ditolak
                KlaimPenemuan::where('id_barang', $barang->id)
                    ->where('id', '!=', $klaim->id)
                    ->where('status_klaim', 'menunggu_verifikasi_pemilik')
                    ->update(['status_klaim' => 'ditolak_pemilik']);

                // Notifikasi
                Notifikasi::create([
                    'id_pengguna' => $klaim->id_penemu,
                    'judul' => 'Klaim Diterima',
                    'pesan' => 'Klaim Anda untuk ' . $barang->nama_barang . ' diterima. Silakan hubungi pemilik.',
                ]);

            } elseif ($newStatus == 'ditolak_pemilik' || $newStatus == 'ditolak_admin') {

                Notifikasi::create([
                    'id_pengguna' => $klaim->id_penemu,
                    'judul' => 'Klaim Ditolak',
                    'pesan' => 'Maaf, klaim Anda untuk ' . $barang->nama_barang . ' ditolak.',
                ]);

                // Cek apakah masih ada klaim lain yang pending?
                $pendingClaims = KlaimPenemuan::where('id_barang', $barang->id)
                    ->where('status_klaim', 'menunggu_verifikasi_pemilik')
                    ->exists();

                // Cek apakah ada klaim yang DITERIMA?
                $acceptedClaims = KlaimPenemuan::where('id_barang', $barang->id)
                    ->where('status_klaim', 'diterima_pemilik')
                    ->exists();

                // Jika tidak ada yang pending DAN tidak ada yang diterima (semua ditolak), reset barang ke Open
                if (!$pendingClaims && !$acceptedClaims) {
                    $barang->status = 'open';
                    $barang->status_verifikasi = 'belum_diverifikasi';
                    $barang->save();
                }
            }

            DB::commit();
            return response()->json([
                'success' => true,
                'message' => 'Status klaim diperbarui',
                'data' => $klaim
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['message' => 'Error: ' . $e->getMessage()], 500);
        }
    }
}
