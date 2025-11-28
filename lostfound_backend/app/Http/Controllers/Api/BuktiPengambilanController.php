<?php
namespace App\Http\Controllers\Api;
use App\Http\Controllers\Controller;
use App\Http\Requests\StoreBuktiRequest;
use App\Models\BuktiPengambilan;
use App\Models\Barang;
use App\Models\Notifikasi;
use Illuminate\Support\Facades\Storage;

class BuktiPengambilanController extends Controller
{
    public function store(StoreBuktiRequest $req)
    {
        $data = $req->validated();
        $barang = Barang::findOrFail($data['id_barang']);

        $path = $req->file('foto_bukti')->store('bukti','public');
        $data['foto_bukti'] = '/storage/'.$path;
        $data['id_admin'] = auth()->id();

        $bukti = BuktiPengambilan::create($data);

        // Update barang status done
        $barang->update(['status'=>'selesai']);

        // Create notifikasi
        Notifikasi::create([
            'id_pengguna'=>$barang->id_pelapor,
            'judul'=>'Barang Telah Diambil',
            'pesan'=>"Barang Anda '{$barang->nama_barang}' telah diambil. Terima kasih."
        ]);

        return response()->json($bukti,201);
    }
}
