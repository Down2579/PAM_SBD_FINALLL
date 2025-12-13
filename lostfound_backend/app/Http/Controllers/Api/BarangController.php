<?php
namespace App\Http\Controllers\Api;
use App\Http\Controllers\Controller;
use App\Http\Requests\StoreBarangRequest;
use App\Http\Requests\StoreBarangRequest as UpdateBarangRequest;
use App\Http\Resources\BarangResource;
use App\Models\Barang;
use App\Models\FotoBarang;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use App\Models\KlaimPenemuan;
use App\Models\BuktiPengambilan;

class BarangController extends Controller
{
    public function index(Request $req)
    {
        $q = Barang::with(['pelapor','kategori','lokasi','foto']);
        if($req->filled('tipe')) $q->where('tipe_laporan',$req->tipe);
        if($req->filled('status')) $q->where('status',$req->status);
        if($req->filled('q')) $q->where('nama_barang','ilike','%'.$req->q.'%');
        return BarangResource::collection($q->orderBy('created_at','desc')->paginate(12));
    }

    public function store(StoreBarangRequest $req)
    {
        $data = $req->validated();
        $data['id_pelapor'] = auth()->id();

        if($req->hasFile('gambar')){
            $path = $req->file('gambar')->store('barang','public');
            $data['gambar_url'] = '/storage/'.$path;
        }
        $barang = Barang::create($data);

        // Handle additional photos (foto_lain[])
        if($req->hasFile('foto_lain')){
            foreach($req->file('foto_lain') as $file){
                $p = $file->store('barang','public');
                FotoBarang::create(['id_barang'=>$barang->id,'url_foto'=>'/storage/'.$p]);
            }
        }

        return new BarangResource($barang->load(['pelapor','kategori','lokasi','foto']));
    }

    public function show(Barang $barang)
    {
        return new BarangResource($barang->load(['pelapor','kategori','lokasi','foto','pengambilan','bukti']));
    }

    public function update(StoreBarangRequest $req, Barang $barang)
    {
        $this->authorize('update',$barang);
        $data = $req->validated();
        if($req->hasFile('gambar')){
            // delete old if exists
            if($barang->gambar_url){
                $oldPath = str_replace('/storage/','',$barang->gambar_url);
                Storage::disk('public')->delete($oldPath);
            }
            $path = $req->file('gambar')->store('barang','public');
            $data['gambar_url'] = '/storage/'.$path;
        }
        $barang->update($data);
        return new BarangResource($barang->fresh());
    }

    public function destroy($id)
    {
        // 1. Cari Barang Manual (Lebih aman daripada Route Binding untuk debugging)
        $barang = Barang::find($id);

        if (!$barang) {
            return response()->json(['message' => 'Barang tidak ditemukan'], 404);
        }

        // 2. CEK HAK AKSES (Gantikan $this->authorize)
        $user = auth()->user();

        // Logika: Boleh hapus JIKA (Role adalah Admin) ATAU (User adalah Pemilik Barang)
        if ($user->role !== 'admin' && $user->id !== $barang->id_pelapor) {
            return response()->json(['message' => 'Anda tidak memiliki izin menghapus barang ini'], 403);
        }

        try {
            // --- MULAI BERSIH-BERSIH DATA TERKAIT ---

            // A. Hapus Foto Utama dari Storage
            if ($barang->gambar_url) {
                $oldPath = str_replace('/storage/', '', $barang->gambar_url);
                // Cek dulu apakah file ada biar gak error
                if(Storage::disk('public')->exists($oldPath)) {
                    Storage::disk('public')->delete($oldPath);
                }
            }

            // B. Hapus Foto Tambahan (Looping hapus file fisik & record db)
            $fotoLain = FotoBarang::where('id_barang', $barang->id)->get();
            foreach ($fotoLain as $foto) {
                if ($foto->url_foto) {
                    $path = str_replace('/storage/', '', $foto->url_foto);
                    if(Storage::disk('public')->exists($path)) {
                        Storage::disk('public')->delete($path);
                    }
                }
                $foto->delete();
            }

            // C. Hapus Data Klaim (PENTING: Penyebab error SQL Integrity biasanya disini)
            KlaimPenemuan::where('id_barang', $barang->id)->delete();

            // D. Hapus Bukti Pengambilan (Jika barang sudah pernah diselesaikan/diupload bukti)
            // Cek apakah tabel/model BuktiPengambilan ada di aplikasi Anda
            // Jika ada, uncomment baris di bawah:
             BuktiPengambilan::where('id_barang', $barang->id)->delete();

            // --- AKHIR BERSIH-BERSIH ---

            // 3. Akhirnya, Hapus Barang itu sendiri
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

    // upload single foto tambahan
    public function uploadFoto(Request $req, Barang $barang)
    {
        $this->authorize('update',$barang);
        $req->validate(['foto'=>'required|image|max:5120']);
        $p = $req->file('foto')->store('barang','public');
        $foto = FotoBarang::create(['id_barang'=>$barang->id,'url_foto'=>'/storage/'.$p]);
        return response()->json($foto,201);
    }
}
