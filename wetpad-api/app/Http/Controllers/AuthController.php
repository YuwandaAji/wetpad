<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules\Password;

class AuthController extends Controller
{
    // cek ketersediaan email / username saat mengetik
    public function check(Request $r)
    {
        return $this->ok([
            'email_taken' => $r->filled('email') && User::where('email', $r->email)->exists(),
            'username_taken' => $r->filled('username') && User::where('username', $r->username)->exists(),
        ]);
    }

    public function register(Request $r)
    {
        $v = $r->validate([
            'username' => ['required', 'string', 'regex:/^[A-Za-z0-9_]{3,20}$/', 'unique:users,username'],
            'email' => ['required', 'email', 'max:100', 'unique:users,email'],
            'birth_date' => ['required', 'date', 'before_or_equal:-13 years'],
            'pronoun' => ['nullable', 'string', 'max:30'],
            'newsletter' => ['boolean'],
            'terms' => ['accepted'],
            'password' => [
                'required', 'string',
                Password::min(10)->mixedCase()->numbers()->symbols(),
                function ($attribute, $value, $fail) use ($r) {
                    $u = strtolower((string) $r->username);
                    if ($u !== '' && str_contains(strtolower($value), $u)) {
                        $fail('Kata sandi tidak boleh mengandung nama pengguna.');
                    }
                },
            ],
        ], [
            'email.unique' => 'Email ini sudah terdaftar.',
            'username.unique' => 'Nama pengguna ini sudah dipakai.',
            'username.regex' => 'Nama pengguna harus 3-20 karakter: huruf, angka, atau garis bawah.',
            'birth_date.before_or_equal' => 'Kamu harus berusia minimal 13 tahun.',
            'terms.accepted' => 'Wajib mencentang kotak ini.',
        ]);

        $user = User::create([
            'username' => $v['username'],
            'email' => $v['email'],
            'password' => Hash::make($v['password']),
            'birth_date' => $v['birth_date'],
            'pronoun' => $v['pronoun'] ?? null,
            'newsletter' => (bool) ($v['newsletter'] ?? false),
        ]);

        return $this->ok([
            'user' => $user,
            'token' => $user->createToken('mobile')->plainTextToken,
        ], null, 201);
    }

    public function login(Request $r)
    {
        // terima "login" (email atau username); "email" lama tetap diterima
        $r->merge(['login' => $r->input('login', $r->input('email'))]);
        $v = $r->validate([
            'login' => 'required|string',
            'password' => 'required|string',
        ]);

        $user = User::where('email', $v['login'])
            ->orWhere('username', $v['login'])
            ->first();

        if (!$user || !$user->password || !Hash::check($v['password'], $user->password)) {
            return $this->fail('Login gagal. Email/nama pengguna atau kata sandi salah.', 401);
        }

        return $this->ok([
            'user' => $user,
            'token' => $user->createToken('mobile')->plainTextToken,
        ]);
    }

    public function me(Request $r)
    {
        return $this->ok($r->user());
    }

    public function setGenres(Request $r)
    {
        $v = $r->validate([
            'genres' => 'required|array|min:1|max:3',
            'genres.*' => 'string|max:50',
        ]);
        $r->user()->update(['genres' => $v['genres']]);
        return $this->ok($r->user()->fresh());
    }
}