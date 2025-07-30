<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Keuangan;
use App\Models\Tagihan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;

class KeuanganController extends Controller
{
    // Ambil semua data keuangan
    public function index()
    {
        try {
            $data = Keuangan::all()->map(function($keuangan){
                if ($keuangan->foto && !empty($keuangan->foto)) {
                    // Pastikan URL lengkap dengan domain
                    $keuangan->foto = url('storage/' . $keuangan->foto);
                }
                return $keuangan;
            });
            
            Log::info('Keuangan data retrieved successfully', ['count' => count($data)]);
            return response()->json($data);
        } catch (\Exception $e) {
            Log::error('Error retrieving keuangan data: ' . $e->getMessage());
            return response()->json(['error' => 'Internal server error'], 500);
        }
    }

    // Tampilkan data keuangan berdasarkan ID
    public function show($id)
    {
        try {
            $keuangan = Keuangan::find($id);
            if (!$keuangan) {
                return response()->json(['message' => 'Not found'], 404);
            }
            
            if ($keuangan->foto && !empty($keuangan->foto)) {
                $keuangan->foto = url('storage/' . $keuangan->foto);
            }
            
            return response()->json($keuangan);
        } catch (\Exception $e) {
            Log::error('Error retrieving keuangan by ID: ' . $e->getMessage());
            return response()->json(['error' => 'Internal server error'], 500);
        }
    }

    // Simpan data keuangan dan update status tagihan
    public function store(Request $request)
    {
        try {
            // Debug: Log request data
            Log::info('Keuangan store request', [
                'has_file' => $request->hasFile('foto'),
                'all_data' => $request->all()
            ]);

            $data = $request->validate([
                'id_penghuni' => 'required|string|max:30',
                'tagihan_id' => 'required|integer|exists:tagihan,id',
                'bayar' => 'required|numeric',
                'tgl_bayar' => 'required|date',
                'keterangan' => 'nullable|string',
                'foto' => 'nullable|file|image|mimes:jpeg,png,jpg,gif|max:2048',
            ]);

            // Handle upload foto jika ada
            $fotoPath = null;
            if ($request->hasFile('foto')) {
                $foto = $request->file('foto');
                $fotoName = time() . '_' . $foto->getClientOriginalName();
                
                // Pastikan folder exists
                if (!Storage::exists('public/foto_keuangan')) {
                    Storage::makeDirectory('public/foto_keuangan');
                }
                
                $fotoPath = $foto->storeAs('public/foto_keuangan', $fotoName);
                // Hapus 'public/' dari path untuk database
                $fotoPath = str_replace('public/', '', $fotoPath);
                
                Log::info('File uploaded successfully', [
                    'original_name' => $foto->getClientOriginalName(),
                    'stored_path' => $fotoPath,
                    'file_size' => $foto->getSize()
                ]);
            }

            // Simpan ke tabel keuangan
            $keuangan = Keuangan::create([
                'id_penghuni' => $data['id_penghuni'],
                'bayar' => $data['bayar'],
                'tgl_bayar' => $data['tgl_bayar'],
                'keterangan' => $data['keterangan'] ?? null,
                'foto' => $fotoPath,
            ]);

            // Update status tagihan menjadi Lunas
            $tagihan = Tagihan::find($data['tagihan_id']);
            if ($tagihan) {
                $tagihan->status = 'Lunas';
                $tagihan->save();
                
                Log::info('Tagihan status updated', [
                    'tagihan_id' => $tagihan->id,
                    'new_status' => 'Lunas'
                ]);
            }

            // Tambahkan URL foto ke response
            if ($keuangan->foto && !empty($keuangan->foto)) {
                $keuangan->foto = url('storage/' . $keuangan->foto);
            }

            Log::info('Keuangan created successfully', [
                'keuangan_id' => $keuangan->id,
                'has_foto' => !empty($keuangan->foto)
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Pembayaran berhasil',
                'keuangan' => $keuangan,
                'tagihan' => $tagihan,
            ], 201);
            
        } catch (\Illuminate\Validation\ValidationException $e) {
            Log::error('Validation error in keuangan store: ' . json_encode($e->errors()));
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            Log::error('Error creating keuangan: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Internal server error: ' . $e->getMessage()
            ], 500);
        }
    }

    // Update data keuangan
    public function update(Request $request, $id)
    {
        try {
            $keuangan = Keuangan::find($id);
            if (!$keuangan) {
                return response()->json(['message' => 'Not found'], 404);
            }

            $data = $request->validate([
                'id_penghuni' => 'sometimes|string|max:30',
                'bayar' => 'sometimes|numeric',
                'tgl_bayar' => 'sometimes|date',
                'keterangan' => 'sometimes|string',
                'foto' => 'sometimes|file|image|mimes:jpeg,png,jpg,gif|max:2048',
            ]);

            // Handle upload foto jika ada
            if ($request->hasFile('foto')) {
                // Hapus foto lama jika ada
                if ($keuangan->foto && Storage::exists('public/' . $keuangan->foto)) {
                    Storage::delete('public/' . $keuangan->foto);
                }
                
                $foto = $request->file('foto');
                $fotoName = time() . '_' . $foto->getClientOriginalName();
                $fotoPath = $foto->storeAs('public/foto_keuangan', $fotoName);
                $data['foto'] = str_replace('public/', '', $fotoPath);
            }

            $keuangan->update($data);

            // Tambahkan URL foto ke response
            if ($keuangan->foto && !empty($keuangan->foto)) {
                $keuangan->foto = url('storage/' . $keuangan->foto);
            }

            return response()->json($keuangan);
        } catch (\Exception $e) {
            Log::error('Error updating keuangan: ' . $e->getMessage());
            return response()->json(['error' => 'Internal server error'], 500);
        }
    }

    // Hapus data keuangan
    public function destroy($id)
    {
        try {
            $keuangan = Keuangan::find($id);
            if (!$keuangan) {
                return response()->json(['message' => 'Not found'], 404);
            }

            // Hapus foto dari storage jika ada
            if ($keuangan->foto && Storage::exists('public/' . $keuangan->foto)) {
                Storage::delete('public/' . $keuangan->foto);
            }

            $keuangan->delete();

            return response()->json(['message' => 'Deleted']);
        } catch (\Exception $e) {
            Log::error('Error deleting keuangan: ' . $e->getMessage());
            return response()->json(['error' => 'Internal server error'], 500);
        }
    }

    // Method untuk test upload file
    public function testUpload(Request $request)
    {
        try {
            if ($request->hasFile('foto')) {
                $foto = $request->file('foto');
                $fotoName = time() . '_' . $foto->getClientOriginalName();
                
                // Pastikan folder exists
                if (!Storage::exists('public/foto_keuangan')) {
                    Storage::makeDirectory('public/foto_keuangan');
                }
                
                $fotoPath = $foto->storeAs('public/foto_keuangan', $fotoName);
                $relativePath = str_replace('public/', '', $fotoPath);
                $fullUrl = url('storage/' . $relativePath);
                
                return response()->json([
                    'success' => true,
                    'message' => 'File uploaded successfully',
                    'file_name' => $fotoName,
                    'file_path' => $relativePath,
                    'file_url' => $fullUrl,
                    'file_size' => $foto->getSize(),
                    'mime_type' => $foto->getMimeType()
                ]);
            }
            
            return response()->json([
                'success' => false,
                'message' => 'No file uploaded'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }
} 