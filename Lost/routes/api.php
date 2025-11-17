<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\BarangController;
use App\Http\Controllers\KlaimController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {

    // Barang
    Route::get('/barang', [BarangController::class, 'index']);
    Route::post('/barang', [BarangController::class, 'store']);
    Route::get('/barang/{id}', [BarangController::class, 'show']);

    // Klaim
    Route::post('/klaim', [KlaimController::class, 'store']);
    Route::post('/klaim/{id}/approve', [KlaimController::class, 'approve']);
    Route::post('/klaim/{id}/reject', [KlaimController::class, 'reject']);
});
