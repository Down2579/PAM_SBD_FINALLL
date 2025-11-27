<?php
namespace App\Http\Controllers\Api;
use App\Http\Controllers\Controller;
use App\Http\Resources\NotifikasiResource;
use App\Models\Notifikasi;
use Illuminate\Http\Request;

class NotifikasiController extends Controller
{
    public function index(Request $req)
    {
        $q = Notifikasi::where('id_pengguna', auth()->id())->orderBy('created_at','desc');
        return NotifikasiResource::collection($q->paginate(20));
    }

    public function markRead($id)
    {
        $n = Notifikasi::where('id_pengguna', auth()->id())->where('id',$id)->firstOrFail();
        $n->update(['sudah_dibaca'=>true]);
        return new NotifikasiResource($n);
    }
}
