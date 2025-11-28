<?php
namespace App\Http\Controllers\Api;
use App\Http\Controllers\Controller;
use App\Http\Requests\RegisterRequest;
use App\Http\Requests\LoginRequest;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Http\Request;

class AuthController extends Controller
{
    public function register(RegisterRequest $req)
    {
        $data = $req->validated();
        $data['password'] = Hash::make($data['password']);
        $user = User::create($data);
        $token = $user->createToken('api-token')->plainTextToken;
        return response()->json(['user'=>$user,'token'=>$token],201);
    }

    public function login(LoginRequest $req)
    {
        $creds = $req->validated();
        $user = User::where('email',$creds['email'])->first();
        if(!$user || !Hash::check($creds['password'],$user->password)){
            return response()->json(['message'=>'Credentials invalid'],401);
        }
        $token = $user->createToken('api-token')->plainTextToken;
        return response()->json(['user'=>$user,'token'=>$token]);
    }

    public function logout(Request $req)
    {
        $req->user()->currentAccessToken()->delete();
        return response()->json(['message'=>'Logged out']);
    }
}
