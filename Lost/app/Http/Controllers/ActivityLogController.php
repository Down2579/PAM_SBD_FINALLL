<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\ActivityLog;

class ActivityLogController extends Controller
{
    // Ambil log aktivitas, bisa dipaginasi
    public function index(Request $request)
    {
        // Hanya tampilkan log terbaru, dan support pagination
        $perPage = $request->query('per_page', 30);

        $logs = ActivityLog::orderBy('created_at', 'desc')->paginate($perPage);

        return response()->json($logs);
    }
}
