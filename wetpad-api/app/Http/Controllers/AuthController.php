<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function register(Request $r)
    {
        $v = $r->validate([
            'username' => 'required|string|max:50|unique:users',
            'email'    => 'required|email|max:100|unique:users',
            'password' => 'required|string|min:6',
        ]);
        $v['password'] = Hash::make($v['password']);
        $user = User::create($v);
        return $this->ok([
            'user' => $user,
            'token' => $user->createToken('mobile')->plainTextToken,
        ], null, 201);
    }

    public function login(Request $r)
    {
        $r->validate(['email' => 'required|email', 'password' => 'required']);
        $user = User::where('email', $r->email)->first();
        if (!$user || !Hash::check($r->password, $user->password)) {
            return $this->fail('Email atau password salah', 401);
        }
        return $this->ok([
            'user' => $user,
            'token' => $user->createToken('mobile')->plainTextToken,
        ]);
    }

    public function me(Request $r) { return $this->ok($r->user()); }
}
