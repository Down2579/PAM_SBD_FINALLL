<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Lokasi;
use Illuminate\Http\Request;
use App\Http\Requests\StoreLokasiRequest;
use App\Http\Requests\UpdateLokasiRequest;

class LokasiController extends Controller
{
    public function index()
    {
        try {
            $data = Lokasi::all();
            return response()->json([
                'success' => true,
                'message' => 'Data lokasi berhasil diambil.',
                'data' => $data
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil data lokasi.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function store(StoreLokasiRequest $request)
    {
        try {
            $data = Lokasi::create($request->validated());

            return response()->json([
                'success' => true,
                'message' => 'Lokasi berhasil ditambahkan.',
                'data' => $data
            ], 201);

        } catch (\Exception $e) {

            return response()->json([
                'success' => false,
                'message' => 'Gagal menambahkan lokasi.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function show($id)
    {
        $lokasi = Lokasi::find($id);

        if (!$lokasi) {
            return response()->json([
                'success' => false,
                'message' => 'Lokasi tidak ditemukan.'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Detail lokasi berhasil diambil.',
            'data' => $lokasi
        ]);
    }

    public function update(UpdateLokasiRequest $request, $id)
    {
        $lokasi = Lokasi::find($id);

        if (!$lokasi) {
            return response()->json([
                'success' => false,
                'message' => 'Lokasi tidak ditemukan.'
            ], 404);
        }

        try {
            $lokasi->update($request->validated());

            return response()->json([
                'success' => true,
                'message' => 'Lokasi berhasil diperbarui.',
                'data' => $lokasi
            ]);

        } catch (\Exception $e) {

            return response()->json([
                'success' => false,
                'message' => 'Gagal memperbarui lokasi.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function destroy($id)
    {
        $lokasi = Lokasi::find($id);

        if (!$lokasi) {
            return response()->json(['success' => false, 'message' => 'Lokasi tidak ditemukan'], 404);
        }

        if ($lokasi->barang()->exists()) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal: Lokasi ini sedang digunakan oleh data barang.'
            ], 409);
        }

        $lokasi->delete();

        return response()->json(['success' => true, 'message' => 'Lokasi berhasil dihapus']);
    }
}
