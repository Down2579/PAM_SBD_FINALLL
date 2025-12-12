<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BarangController;
use App\Http\Controllers\Api\PengambilanController;
use App\Http\Controllers\Api\BuktiPengambilanController;
use App\Http\Controllers\Api\NotifikasiController;
use App\Http\Controllers\Api\KategoriController;
use App\Http\Controllers\Api\LokasiController;

// Public
Route::post('register', [AuthController::class,'register']);
Route::post('login', [AuthController::class,'login']);

// Protected
Route::middleware('auth:sanctum')->group(function(){
    Route::post('logout',[AuthController::class,'logout']);

    Route::get('barang', [BarangController::class,'index']);
    Route::post('barang', [BarangController::class,'store']);
    Route::get('barang/{barang}', [BarangController::class,'show']);
    Route::put('barang/{barang}', [BarangController::class,'update']);
    Route::delete('barang/{barang}', [BarangController::class,'destroy']);
    Route::post('barang/{barang}/foto', [BarangController::class,'uploadFoto']);

    Route::get('pengambilan', [PengambilanController::class,'index']);
    Route::post('pengambilan', [PengambilanController::class,'store']);
    Route::patch('pengambilan/{pengambilan}/status', [PengambilanController::class,'updateStatus']);

    Route::get('klaim-penemuan', [KlaimPenemuanController::class, 'index']);
    Route::post('klaim-penemuan', [KlaimPenemuanController::class, 'store']);
    Route::patch('klaim-penemuan/{id}/status', [KlaimPenemuanController::class, 'updateStatus']);

    Route::post('bukti', [BuktiPengambilanController::class,'store']);

    Route::get('notifikasi', [NotifikasiController::class,'index']);
    Route::patch('notifikasi/{id}/read',[NotifikasiController::class,'markRead']);

    Route::get('kategori', [KategoriController::class,'index']);
    Route::post('kategori', [KategoriController::class,'store']);
    Route::get('kategori/{kategori}', [KategoriController::class,'show']);
    Route::put('kategori/{kategori}', [KategoriController::class,'update']);
    Route::delete('kategori/{kategori}', [KategoriController::class,'destroy']);

    Route::get('lokasi', [LokasiController::class,'index']);
    Route::post('lokasi', [LokasiController::class,'store']);
    Route::get('lokasi/{lokasi}', [LokasiController::class,'show']);
    Route::put('lokasi/{lokasi}', [LokasiController::class,'update']);
    Route::delete('lokasi/{lokasi}', [LokasiController::class,'destroy']);

});
