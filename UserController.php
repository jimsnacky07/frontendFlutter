<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Penghuni;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;
use Illuminate\Support\Facades\Storage;

class UserController extends Controller
{
    // Tampilkan semua user beserta penghuni terkait
    public function index()
    {
        $users = User::with('penghuni')->get();
        $users = $users->map(function ($user) {
            $user->foto = $user->foto ? asset('storage/' . $user->foto) : null;
            return $user;
        });
        return response()->json($users);
    }

    // Simpan user baru
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:6',
            'penghuni_id' => 'nullable|exists:penghuni,id',
            'foto' => 'nullable|image|mimes:jpeg,png,jpg,svg',
            'role' => 'required|string',
        ]);
        if ($request->hasFile('foto')) {
            $fotoPath = $request->file('foto')->store('foto_user', 'public');
            $validated['foto'] = $fotoPath;
        }

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'foto' => $validated['foto'] ?? null,
            'role' => $validated['role'],
        ]);

        // Relasikan ke penghuni jika ada
        if (!empty($validated['penghuni_id'])) {
            $penghuni = Penghuni::find($validated['penghuni_id']);
            $penghuni->user_id = $user->id;
            $penghuni->save();
        }

        return response()->json($user->load('penghuni'), 201);
    }

    // Tampilkan detail user
    public function show($id)
    {
        $user = User::with('penghuni')->findOrFail($id);
        $user->foto = $user->foto ? asset('storage/' . $user->foto) : null;
        return response()->json($user);
    }

    // Update user
    public function update(Request $request, $id)
    {
        $user = User::findOrFail($id);
        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'email' => ['sometimes', 'required', 'email', Rule::unique('users')->ignore($user->id)],
            'password' => 'nullable|string|min:6',
            'penghuni_id' => 'nullable|exists:penghuni,id',
            'foto' => 'nullable|image|mimes:jpeg,png,jpg,svg',
            'role' => 'sometimes|required|string',
        ]);
        if ($request->hasFile('foto')) {
            // Hapus foto lama jika ada
            if ($user->foto) {
                Storage::disk('public')->delete($user->foto);
            }
            $fotoPath = $request->file('foto')->store('foto_user', 'public');
            $validated['foto'] = $fotoPath;
        }
        if (isset($validated['name'])) $user->name = $validated['name'];
        if (isset($validated['email'])) $user->email = $validated['email'];
        if (!empty($validated['password'])) $user->password = Hash::make($validated['password']);
        if (isset($validated['foto'])) $user->foto = $validated['foto'];
        if (isset($validated['role'])) $user->role = $validated['role'];
        $user->save();

        // Update relasi penghuni
        if (array_key_exists('penghuni_id', $validated)) {
            // Unlink penghuni lama
            if ($user->penghuni) {
                $user->penghuni->user_id = null;
                $user->penghuni->save();
            }
            // Link penghuni baru
            if ($validated['penghuni_id']) {
                $penghuni = Penghuni::find($validated['penghuni_id']);
                $penghuni->user_id = $user->id;
                $penghuni->save();
            }
        }

        return response()->json($user->load('penghuni'));
    }

    // Hapus user
    public function destroy($id)
    {
        $user = User::findOrFail($id);
        // Unlink penghuni jika ada
        if ($user->penghuni) {
            $user->penghuni->user_id = null;
            $user->penghuni->save();
        }
        $user->delete();
        return response()->json(['message' => 'User deleted']);
    }

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required',
            'password' => 'required',
        ]);

        $user = User::where('email', $request->email)->first();
        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json(['message' => 'Invalid credentials'], 401);
        }

        $token = $user->createToken('user-token')->plainTextToken;
        return response()->json([
            'message' => 'Login successful',
            'token' => $token,
            'user' => $user
        ]);
    }

    // Method untuk mengubah password user yang sedang login
    public function changePassword(Request $request)
    {
        try {
            $request->validate([
                'old_password' => 'required|string',
                'new_password' => 'required|string|min:6',
                'new_password_confirmation' => 'required|same:new_password',
            ]);

            $user = auth()->user(); // Ambil user yang sedang login
            
            // Cek password lama
            if (!Hash::check($request->old_password, $user->password)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Password lama tidak sesuai'
                ], 400);
            }

            // Update password baru
            $user->password = Hash::make($request->new_password);
            $user->save();

            return response()->json([
                'success' => true,
                'message' => 'Password berhasil diubah'
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengubah password: ' . $e->getMessage()
            ], 500);
        }
    }
} 