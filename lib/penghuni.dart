import 'package:flutter/material.dart';
import 'api_service.dart';

class PenghuniPage extends StatefulWidget {
  @override
  _PenghuniPageState createState() => _PenghuniPageState();
}

class _PenghuniPageState extends State<PenghuniPage> {
  List<Penghuni> residents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchResidents();
  }

  void fetchResidents() async {
    try {
      final response = await ApiService().get('penghuni');
      // Asumsi response: { "success": true, "data": [ ... ] } atau { "success": true, "data": { ... } }
      final data = response['data'];
      List<Penghuni> parsed;
      if (data is List) {
        parsed = data.map((e) => Penghuni.fromJson(e)).toList();
      } else if (data is Map) {
        parsed = [Penghuni.fromJson(Map<String, dynamic>.from(data))];
      } else {
        parsed = [];
      }
      setState(() {
        residents = parsed;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching residents: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F5F3),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFDFE3E6), width: 2),
            ),
          ),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Penghuni',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5A6A73),
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ),
      body: Container(
        color: Color(0xFFF6F5F3),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                itemCount: residents.length,
                itemBuilder: (context, index) {
                  final resident = residents[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: Card(
                      color: Colors.white,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Color(0xFFD1D2CD),
                                  radius: 32,
                                  child: Icon(Icons.people, color: Color(0xFF5A6A73), size: 32),
                                ),
                                SizedBox(width: 24),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        resident.nama,
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF18323A),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text('ID: ${resident.id}'),
                                      Text('Alamat: ${resident.alamat}'),
                                      Text('No HP: ${resident.nohp}'),
                                      Text('Registrasi: ${resident.registrasi}'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text('Kamar:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('  ID: ${resident.kamar.id}'),
                            Text('  Lantai: ${resident.kamar.lantai}'),
                            Text('  Kapasitas: ${resident.kamar.kapasitas}'),
                            Text('  Fasilitas: ${resident.kamar.fasilitas}'),
                            Text('  Tarif: Rp ${resident.kamar.tarif}'),
                            Text('  Max Penghuni: ${resident.kamar.maxPenghuni}'),
                            if (resident.keuangan.isNotEmpty) ...[
                              SizedBox(height: 8),
                              Text('Keuangan:', style: TextStyle(fontWeight: FontWeight.bold)),
                              ...resident.keuangan.map((k) => Padding(
                                padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                                child: Text('- ${k.tglBayar}: Rp ${k.bayar} (${k.keterangan})'),
                              )),
                            ],
                            if (resident.tagihan.isNotEmpty) ...[
                              SizedBox(height: 8),
                              Text('Tagihan:', style: TextStyle(fontWeight: FontWeight.bold)),
                              ...resident.tagihan.map((t) => Padding(
                                padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                                child: Text('- ${t.bulan} ${t.tahun}: Rp ${t.tagihan} (${t.status})'),
                              )),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

// Tambahkan model data sesuai struktur API baru
class Kamar {
  final String id;
  final int lantai;
  final String kapasitas;
  final String fasilitas;
  final int tarif;
  final int maxPenghuni;

  Kamar({
    required this.id,
    required this.lantai,
    required this.kapasitas,
    required this.fasilitas,
    required this.tarif,
    required this.maxPenghuni,
  });

  factory Kamar.fromJson(Map<String, dynamic> json) {
    return Kamar(
      id: json['id'] ?? '',
      lantai: json['lantai'] ?? 0,
      kapasitas: json['kapasitas'] ?? '',
      fasilitas: json['fasilitas'] ?? '',
      tarif: json['tarif'] ?? 0,
      maxPenghuni: json['max_penghuni'] ?? 0,
    );
  }
}

class Keuangan {
  final String id;
  final String idPenghuni;
  final String tglBayar;
  final int bayar;
  final String keterangan;

  Keuangan({
    required this.id,
    required this.idPenghuni,
    required this.tglBayar,
    required this.bayar,
    required this.keterangan,
  });

  factory Keuangan.fromJson(Map<String, dynamic> json) {
    return Keuangan(
      id: json['id'] ?? '',
      idPenghuni: json['id_penghuni'] ?? '',
      tglBayar: json['tgl_bayar'] ?? '',
      bayar: json['bayar'] ?? 0,
      keterangan: json['keterangan'] ?? '',
    );
  }
}

class Tagihan {
  final int id;
  final String idPenghuni;
  final String bulan;
  final String tahun;
  final String tagihan;
  final String status;
  final String tanggal;

  Tagihan({
    required this.id,
    required this.idPenghuni,
    required this.bulan,
    required this.tahun,
    required this.tagihan,
    required this.status,
    required this.tanggal,
  });

  factory Tagihan.fromJson(Map<String, dynamic> json) {
    return Tagihan(
      id: json['id'] ?? 0,
      idPenghuni: json['id_penghuni'] ?? '',
      bulan: json['bulan'] ?? '',
      tahun: json['tahun'] ?? '',
      tagihan: json['tagihan'] ?? '',
      status: json['status'] ?? '',
      tanggal: json['tanggal'] ?? '',
    );
  }
}

class Penghuni {
  final String id;
  final String nama;
  final String alamat;
  final String nohp;
  final String registrasi;
  final Kamar kamar;
  final List<Keuangan> keuangan;
  final List<Tagihan> tagihan;

  Penghuni({
    required this.id,
    required this.nama,
    required this.alamat,
    required this.nohp,
    required this.registrasi,
    required this.kamar,
    required this.keuangan,
    required this.tagihan,
  });

  factory Penghuni.fromJson(Map<String, dynamic> json) {
    return Penghuni(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      alamat: json['alamat'] ?? '',
      nohp: json['nohp'] ?? '',
      registrasi: json['registrasi'] ?? '',
      kamar: Kamar.fromJson(json['kamar'] ?? {}),
      keuangan: (json['keuangan'] as List<dynamic>? ?? []).map((e) => Keuangan.fromJson(e)).toList(),
      tagihan: (json['tagihan'] as List<dynamic>? ?? []).map((e) => Tagihan.fromJson(e)).toList(),
    );
  }
}