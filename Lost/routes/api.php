<?php

use Illuminate\Support\Facades\Route;

use App\Http\Controllers\AuthController;
use App\Http\Controllers\BarangController;
use App\Http\Controllers\PengambilanController;
use App\Http\Controllers\KategoriController;
use App\Http\Controllers\LokasiController;
use App\Http\Controllers\FotoBarangController;
use App\Http\Controllers\BuktiPengambilanController;
use App\Http\Controllers\NotifikasiController;
use App\Http\Controllers\ActivityLogController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {

    Route::get('/barang', [BarangController::class, 'index']);
    Route::post('/barang', [BarangController::class, 'store']);
    Route::get('/barang/{id}', [BarangController::class, 'show']);

    Route::post('/pengambilan', [PengambilanController::class, 'store']);
    Route::post('/pengambilan/{id}/approve', [PengambilanController::class, 'approve']);
    Route::post('/pengambilan/{id}/reject', [PengambilanController::class, 'reject']);

    Route::get('/kategori', [KategoriController::class, 'index']);
    Route::post('/kategori', [KategoriController::class, 'store']);

    Route::get('/lokasi', [LokasiController::class, 'index']);
    Route::post('/lokasi', [LokasiController::class, 'store']);

    Route::get('/barang/{id_barang}/photos', [FotoBarangController::class, 'index']);
    Route::post('/barang/{id_barang}/photos', [FotoBarangController::class, 'store']);
    Route::delete('/photos/{id}', [FotoBarangController::class, 'destroy']);

    Route::get('/barang/{id_barang}/pickup-proof', [BuktiPengambilanController::class, 'show']);
    Route::post('/barang/{id_barang}/pickup-proof', [BuktiPengambilanController::class, 'store']);

    Route::get('/notifications', [NotifikasiController::class, 'index']);
    Route::post('/notifications', [NotifikasiController::class, 'store']);
    Route::post('/notifications/read-all', [NotifikasiController::class, 'markAllRead']);

    Route::get('/activity-logs', [ActivityLogController::class, 'index']);
});
