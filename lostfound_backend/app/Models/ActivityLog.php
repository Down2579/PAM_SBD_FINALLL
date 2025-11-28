<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class ActivityLog extends Model
{
    protected $table = 'activity_logs';
    public $timestamps = false;
    protected $fillable = ['id_pengguna','aktivitas','metadata','created_at'];
    protected $casts = ['metadata'=>'array'];
    public function pengguna(){ return $this->belongsTo(User::class,'id_pengguna'); }
}
