import 'package:flutter/material.dart';
import 'api_service.dart';

class KamarPage extends StatefulWidget {
  @override
  _KamarPageState createState() => _KamarPageState();
}

// Tambahkan model data Kamar dan Penghuni sesuai struktur API
class Penghuni {
  final String id;
  final String nama;
  final String nohp;
  final String registrasi;

  Penghuni({required this.id, required this.nama, required this.nohp, required this.registrasi});

  factory Penghuni.fromJson(Map<String, dynamic> json) {
    return Penghuni(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      nohp: json['nohp'] ?? '',
      registrasi: json['registrasi'] ?? '',
    );
  }
}

class Kamar {
  final String id;
  final int lantai;
  final String kapasitas;
  final String fasilitas;
  final int tarif;
  final int maxPenghuni;
  final String status;
  final int currentOccupants;
  final int availableSlots;
  final List<Penghuni> penghuni;

  Kamar({
    required this.id,
    required this.lantai,
    required this.kapasitas,
    required this.fasilitas,
    required this.tarif,
    required this.maxPenghuni,
    required this.status,
    required this.currentOccupants,
    required this.availableSlots,
    required this.penghuni,
  });

  factory Kamar.fromJson(Map<String, dynamic> json) {
    return Kamar(
      id: json['id'] ?? '',
      lantai: json['lantai'] ?? 0,
      kapasitas: json['kapasitas'] ?? '',
      fasilitas: json['fasilitas'] ?? '',
      tarif: json['tarif'] ?? 0,
      maxPenghuni: json['max_penghuni'] ?? 0,
      status: json['status'] ?? '',
      currentOccupants: json['current_occupants'] ?? 0,
      availableSlots: json['available_slots'] ?? 0,
      penghuni: (json['penghuni'] as List<dynamic>? ?? [])
          .map((e) => Penghuni.fromJson(e))
          .toList(),
    );
  }
}

class _KamarPageState extends State<KamarPage> {
  List<Kamar> rooms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  void fetchRooms() async {
    try {
      final response = await ApiService().get('kamar');
      // Asumsi response: { "success": true, "data": [ ... ] }
      final List<dynamic> data = response['data'] ?? [];
      setState(() {
        rooms = data.map((e) => Kamar.fromJson(e)).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching rooms: $e');
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
            'Kamar',
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
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final room = rooms[index];
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
                                  child: Icon(Icons.bed, color: Color(0xFF5A6A73), size: 32),
                                ),
                                SizedBox(width: 24),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Kamar: ${room.id}',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF18323A),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text('Lantai: ${room.lantai}'),
                                      Text('Kapasitas: ${room.kapasitas}'),
                                      Text('Fasilitas: ${room.fasilitas}'),
                                      Text('Tarif: Rp ${room.tarif}'),
                                      Text('Status: ${room.status}'),
                                      Text('Penghuni: ${room.currentOccupants}/${room.maxPenghuni}'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (room.penghuni.isNotEmpty) ...[
                              SizedBox(height: 12),
                              Text('Daftar Penghuni:', style: TextStyle(fontWeight: FontWeight.bold)),
                              ...room.penghuni.map((p) => Padding(
                                padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                                child: Text('- ${p.nama} (${p.nohp}) sejak ${p.registrasi}'),
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