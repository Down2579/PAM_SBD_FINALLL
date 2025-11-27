<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Notifikasi;

class NotifikasiController extends Controller
{
    // Ambil semua notifikasi dari user yang login
    public function index()
    {
        $userId = auth()->id();

        $notifs = Notifikasi::where('id_pengguna', $userId)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json($notifs);
    }

    // Admin atau sistem bisa membuat notifikasi manual
    public function store(Request $request)
    {
        $request->validate([
            'id_pengguna' => 'required|exists:users,id',
            'judul' => 'required|string|max:150',
            'pesan' => 'required|string',
        ]);

        $notif = Notifikasi::create([
            'id_pengguna' => $request->id_pengguna,
            'judul' => $request->judul,
            'pesan' => $request->pesan,
            'sudah_dibaca' => false
        ]);

        return response()->json($notif, 201);
    }

    // Tandai semua notifikasi user saat ini sebagai dibaca
    public function markAllRead()
    {
        $userId = auth()->id();
        Notifikasi::where('id_pengguna', $userId)->update(['sudah_dibaca' => true]);

        return response()->json(['message' => 'Semua notifikasi telah ditandai dibaca.']);
    }
}
