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

    public function destroy(Barang $barang)
    {
        $this->authorize('delete',$barang);
        // delete related images
        if($barang->gambar_url){
            $oldPath = str_replace('/storage/','',$barang->gambar_url);
            Storage::disk('public')->delete($oldPath);
        }
        $barang->delete();
        return response()->json(['message'=>'Barang dihapus']);
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
