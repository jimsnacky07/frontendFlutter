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

            $request->validate([
                'id_penghuni' => 'required|string|max:30',
                'bayar' => 'required|numeric',
                'tgl_bayar' => 'required|date',
                'keterangan' => 'nullable|string',
                'foto' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg',
            ]);

            $data = $request->only(['id_penghuni', 'bayar', 'tgl_bayar', 'keterangan']);

            // Handle upload foto jika ada
            if ($request->hasFile('foto')) {
                $data['foto'] = $request->file('foto')->store('foto_keuangan', 'public');
                
                Log::info('File uploaded successfully', [
                    'original_name' => $request->file('foto')->getClientOriginalName(),
                    'stored_path' => $data['foto'],
                    'file_size' => $request->file('foto')->getSize()
                ]);
            }

            // Simpan ke tabel keuangan
            $keuangan = Keuangan::create($data);

            // Update status tagihan menjadi Lunas dan buat tagihan baru
            $tagihan = Tagihan::where('id_penghuni', $data['id_penghuni'])
                ->where('status', 'Belum Lunas')
                ->orderBy('tahun', 'asc')
                ->orderBy('bulan', 'asc')
                ->first();
                
            if ($tagihan) {
                // Update status tagihan menjadi Lunas
                $tagihan->status = 'Lunas';
                $tagihan->save();
                
                Log::info('Tagihan status updated to Lunas', [
                    'tagihan_id' => $tagihan->id,
                    'penghuni_id' => $tagihan->id_penghuni,
                    'bulan' => $tagihan->bulan,
                    'tahun' => $tagihan->tahun,
                    'new_status' => 'Lunas'
                ]);

                // Buat tagihan baru untuk bulan selanjutnya
                $newTagihan = $this->createNextMonthTagihan($tagihan);
                if ($newTagihan) {
                    Log::info('Tagihan baru dibuat untuk bulan selanjutnya', [
                        'new_tagihan_id' => $newTagihan->id,
                        'penghuni_id' => $newTagihan->id_penghuni,
                        'bulan' => $newTagihan->bulan,
                        'tahun' => $newTagihan->tahun,
                        'jumlah' => $newTagihan->tagihan,
                        'status' => $newTagihan->status
                    ]);
                }
            } else {
                Log::warning('Tidak ada tagihan yang belum lunas untuk penghuni ini', [
                    'penghuni_id' => $data['id_penghuni']
                ]);
            }

            // Tambahkan URL foto ke response
            if ($keuangan->fotoExists()) {
                $keuangan->foto = $keuangan->getFotoUrl();
            } else {
                $keuangan->foto = null;
            }

            Log::info('Keuangan created successfully', [
                'keuangan_id' => $keuangan->id,
                'has_foto' => $keuangan->fotoExists()
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

    // Method untuk membuat tagihan bulan selanjutnya
    private function createNextMonthTagihan($currentTagihan)
    {
        try {
            // Ambil bulan dan tahun dari tagihan yang baru dibayar
            $currentMonth = $currentTagihan->bulan;
            $currentYear = $currentTagihan->tahun;
            
            // Tentukan bulan dan tahun selanjutnya
            $nextMonth = $this->getNextMonth($currentMonth);
            $nextYear = $currentYear;
            
            // Jika bulan selanjutnya adalah Januari, tahun bertambah
            if ($nextMonth == 'Januari') {
                $nextYear = $currentYear + 1;
            }
            
            // Cek apakah tagihan untuk bulan selanjutnya sudah ada
            $existingTagihan = Tagihan::where('id_penghuni', $currentTagihan->id_penghuni)
                ->where('bulan', $nextMonth)
                ->where('tahun', $nextYear)
                ->first();
            
            if (!$existingTagihan) {
                // Buat tagihan baru
                $newTagihan = Tagihan::create([
                    'id_penghuni' => $currentTagihan->id_penghuni,
                    'bulan' => $nextMonth,
                    'tahun' => $nextYear,
                    'tagihan' => $currentTagihan->tagihan, // Gunakan jumlah yang sama
                    'status' => 'Belum Lunas',
                ]);
                
                Log::info('New tagihan created', [
                    'penghuni_id' => $currentTagihan->id_penghuni,
                    'bulan' => $nextMonth,
                    'tahun' => $nextYear,
                    'tagihan' => $currentTagihan->tagihan
                ]);
                
                return $newTagihan;
            } else {
                Log::info('Tagihan for next month already exists', [
                    'existing_tagihan_id' => $existingTagihan->id,
                    'bulan' => $nextMonth,
                    'tahun' => $nextYear
                ]);
                return $existingTagihan;
            }
            
        } catch (\Exception $e) {
            Log::error('Error creating next month tagihan: ' . $e->getMessage());
            return null;
        }
    }

    // Helper method untuk mendapatkan bulan selanjutnya
    private function getNextMonth($currentMonth)
    {
        $months = [
            'Januari' => 'Februari',
            'Februari' => 'Maret',
            'Maret' => 'April',
            'April' => 'Mei',
            'Mei' => 'Juni',
            'Juni' => 'Juli',
            'Juli' => 'Agustus',
            'Agustus' => 'September',
            'September' => 'Oktober',
            'Oktober' => 'November',
            'November' => 'Desember',
            'Desember' => 'Januari'
        ];
        
        return $months[$currentMonth] ?? 'Januari';
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
                'tagihan_id' => 'sometimes|integer|exists:tagihan,id',
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