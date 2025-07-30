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
                'tagihan_id' => 'required|integer', // Hapus exists validation untuk input manual
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
                
                // Buat folder jika belum ada
                $folderPath = 'public/foto_keuangan';
                if (!Storage::exists($folderPath)) {
                    Storage::makeDirectory($folderPath);
                    Log::info('Created directory: ' . $folderPath);
                }
                
                // Coba simpan file
                try {
                    $fotoPath = $foto->storeAs($folderPath, $fotoName);
                    
                    // Verifikasi file tersimpan
                    if (Storage::exists($fotoPath)) {
                        Log::info('File uploaded successfully', [
                            'original_name' => $foto->getClientOriginalName(),
                            'stored_path' => $fotoPath,
                            'full_path' => Storage::path($fotoPath),
                            'file_size' => $foto->getSize(),
                            'exists' => Storage::exists($fotoPath)
                        ]);
                        
                        // Hapus 'public/' dari path untuk database
                        $fotoPath = str_replace('public/', '', $fotoPath);
                    } else {
                        Log::error('File upload failed - file does not exist after upload', [
                            'attempted_path' => $fotoPath
                        ]);
                        $fotoPath = null;
                    }
                } catch (\Exception $uploadError) {
                    Log::error('File upload error: ' . $uploadError->getMessage(), [
                        'file_name' => $fotoName,
                        'folder_path' => $folderPath
                    ]);
                    $fotoPath = null;
                }
            }

            // Simpan ke tabel keuangan
            $keuangan = Keuangan::create([
                'id_penghuni' => $data['id_penghuni'],
                'bayar' => $data['bayar'],
                'tgl_bayar' => $data['tgl_bayar'],
                'keterangan' => $data['keterangan'] ?? null,
                'foto' => $fotoPath,
            ]);

            // Update status tagihan menjadi Lunas (hanya jika tagihan_id valid)
            $tagihan = null;
            Log::info('Processing tagihan update', [
                'tagihan_id_received' => $data['tagihan_id'],
                'tagihan_id_type' => gettype($data['tagihan_id']),
                'tagihan_id_gt_zero' => $data['tagihan_id'] > 0
            ]);
            
            if ($data['tagihan_id'] > 0) {
                $tagihan = Tagihan::find($data['tagihan_id']);
                Log::info('Tagihan lookup result', [
                    'tagihan_id' => $data['tagihan_id'],
                    'tagihan_found' => $tagihan ? 'yes' : 'no',
                    'tagihan_data' => $tagihan ? [
                        'id' => $tagihan->id,
                        'status' => $tagihan->status,
                        'id_penghuni' => $tagihan->id_penghuni,
                        'bulan' => $tagihan->bulan,
                        'tahun' => $tagihan->tahun
                    ] : null
                ]);
                
                if ($tagihan) {
                    $oldStatus = $tagihan->status;
                    $tagihan->status = 'Lunas';
                    $saved = $tagihan->save();
                    
                    Log::info('Tagihan status update attempt', [
                        'tagihan_id' => $tagihan->id,
                        'old_status' => $oldStatus,
                        'new_status' => $tagihan->status,
                        'save_success' => $saved,
                        'current_status_after_save' => $tagihan->fresh()->status
                    ]);

                    // Buat tagihan baru untuk bulan selanjutnya
                    $newTagihan = $this->createNextMonthTagihan($tagihan);
                    if ($newTagihan) {
                        Log::info('New tagihan created for next month', [
                            'new_tagihan_id' => $newTagihan->id,
                            'bulan' => $newTagihan->bulan,
                            'tahun' => $newTagihan->tahun
                        ]);
                    }
                } else {
                    Log::warning('Tagihan not found for ID: ' . $data['tagihan_id']);
                    
                    // Debug: cek semua tagihan yang ada
                    $allTagihan = Tagihan::all(['id', 'id_penghuni', 'status', 'bulan', 'tahun']);
                    Log::info('All available tagihan', [
                        'count' => $allTagihan->count(),
                        'tagihan_list' => $allTagihan->toArray()
                    ]);
                }
            } else {
                Log::info('Manual input - no tagihan to update (tagihan_id = 0)');
            }

            // Tambahkan URL foto ke response
            if ($keuangan->foto && !empty($keuangan->foto)) {
                $keuangan->foto = url('storage/' . $keuangan->foto);
            }

            Log::info('Keuangan created successfully', [
                'keuangan_id' => $keuangan->id,
                'has_foto' => !empty($keuangan->foto),
                'foto_path' => $keuangan->foto
            ]);

            $response = [
                'success' => true,
                'message' => 'Pembayaran berhasil',
                'keuangan' => $keuangan,
            ];
            
            if ($tagihan) {
                $response['tagihan'] = $tagihan;
            }
            
            return response()->json($response, 201);
            
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
        if (!$currentTagihan) {
            Log::info('No current tagihan provided for next month creation');
            return null;
        }
        
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
} 