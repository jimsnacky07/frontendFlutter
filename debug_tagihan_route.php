<?php
// Tambahkan route ini di routes/api.php untuk debug tagihan

use App\Models\Tagihan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

// Route untuk cek semua tagihan
Route::get('/debug-tagihan', function() {
    $tagihan = Tagihan::all();
    return response()->json([
        'total_tagihan' => $tagihan->count(),
        'tagihan_list' => $tagihan->map(function($t) {
            return [
                'id' => $t->id,
                'id_penghuni' => $t->id_penghuni,
                'bulan' => $t->bulan,
                'tahun' => $t->tahun,
                'tagihan' => $t->tagihan,
                'status' => $t->status
            ];
        })
    ]);
});

// Route untuk update status tagihan manual
Route::post('/debug-update-tagihan/{id}', function(Request $request, $id) {
    try {
        $tagihan = Tagihan::find($id);
        if (!$tagihan) {
            return response()->json(['error' => 'Tagihan not found'], 404);
        }
        
        $oldStatus = $tagihan->status;
        $tagihan->status = 'Lunas';
        $saved = $tagihan->save();
        
        Log::info('Manual tagihan update', [
            'tagihan_id' => $id,
            'old_status' => $oldStatus,
            'new_status' => $tagihan->status,
            'save_success' => $saved
        ]);
        
        return response()->json([
            'success' => true,
            'tagihan_id' => $id,
            'old_status' => $oldStatus,
            'new_status' => $tagihan->status,
            'save_success' => $saved
        ]);
        
    } catch (\Exception $e) {
        Log::error('Manual tagihan update error: ' . $e->getMessage());
        return response()->json(['error' => $e->getMessage()], 500);
    }
});

// Route untuk cek tagihan by ID
Route::get('/debug-tagihan/{id}', function($id) {
    $tagihan = Tagihan::find($id);
    if (!$tagihan) {
        return response()->json(['error' => 'Tagihan not found'], 404);
    }
    
    return response()->json([
        'id' => $tagihan->id,
        'id_penghuni' => $tagihan->id_penghuni,
        'bulan' => $tagihan->bulan,
        'tahun' => $tagihan->tahun,
        'tagihan' => $tagihan->tagihan,
        'status' => $tagihan->status,
        'fillable' => $tagihan->getFillable(),
        'table' => $tagihan->getTable()
    ]);
}); 