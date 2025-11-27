<?php
namespace App\Http\Controllers\Api;
use App\Http\Controllers\Controller;
use App\Http\Requests\StorePengambilanRequest;
use App\Http\Requests\UpdatePengambilanStatusRequest;
use App\Http\Resources\PengambilanResource;
use App\Models\Pengambilan;
use App\Models\Barang;
use App\Models\Notifikasi;
use Illuminate\Http\Request;

class PengambilanController extends Controller
{
    public function index(Request $req)
    {
        $user = auth()->user();
        if($user->role === 'admin'){
            $q = Pengambilan::with(['barang','pengambil'])->orderBy('created_at','desc');
        } else {
            $q = Pengambilan::with(['barang','pengambil'])->where('id_pengambil',$user->id)->orWhereHas('barang', function($s) use ($user){ $s->where('id_pelapor',$user->id); })->orderBy('created_at','desc');
        }
        return PengambilanResource::collection($q->paginate(12));
    }

    public function store(StorePengambilanRequest $req)
    {
        $userId = auth()->id();
        $data = $req->validated();
        $barang = Barang::findOrFail($data['id_barang']);

        // Prevent self pickup
        if($barang->tipe_laporan === 'hilang' && $barang->id_pelapor == $userId){
            return response()->json(['message'=>'Tidak dapat mengambil barang yang Anda laporkan sendiri.'],422);
        }

        // create pengambilan
        $p = Pengambilan::create([
            'id_barang'=>$barang->id,
            'id_pengambil'=>$userId,
            'pesan_pengambilan'=>$data['pesan_pengambilan'],
            'status_pengambilan'=>'pending'
        ]);

        // update barang status jadi proses_klaim
        $barang->update(['status'=>'proses_klaim']);

        // create notification to pelapor
        Notifikasi::create([
            'id_pengguna'=>$barang->id_pelapor,
            'judul'=>'Permintaan Pengambilan',
            'pesan'=>"Ada permintaan pengambilan untuk barang: {$barang->nama_barang}"
        ]);

        return new PengambilanResource($p->load(['barang','pengambil']));
    }

    public function updateStatus(UpdatePengambilanStatusRequest $req, Pengambilan $pengambilan)
    {
        $validated = $req->validated();
        $old = $pengambilan->status_pengambilan;
        $pengambilan->update(['status_pengambilan'=>$validated['status_pengambilan']]);

        // update barang status
        if($validated['status_pengambilan'] == 'disetujui'){
            $pengambilan->barang->update(['status'=>'selesai']);
        } elseif($validated['status_pengambilan'] == 'ditolak'){
            $pengambilan->barang->update(['status'=>'open']);
        }

        // create notification to pelapor
        Notifikasi::create([
            'id_pengguna'=>$pengambilan->barang->id_pelapor,
            'judul'=>'Status Pengambilan Berubah',
            'pesan'=>"Status pengambilan untuk barang {$pengambilan->barang->nama_barang} berubah menjadi {$validated['status_pengambilan']}"
        ]);

        return new PengambilanResource($pengambilan->fresh());
    }
}
