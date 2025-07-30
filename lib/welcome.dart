import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  final List<Map<String, String>> rules = [
    {
      'title': 'Pembayaran Sewa',
      'desc': 'Pembayaran sewa wajib dilakukan sebelum tanggal 10 setiap bulan. Keterlambatan akan dikenakan denda sesuai ketentuan.'
    },
    {
      'title': 'Tamu & Jam Malam',
      'desc': 'Tamu dilarang menginap tanpa izin pengelola. Jam malam berlaku pukul 22.00 WIB, setelah itu pintu utama akan dikunci.'
    },
    {
      'title': 'Kebersihan',
      'desc': 'Setiap penghuni wajib menjaga kebersihan kamar dan area bersama. Sampah harus dibuang pada tempatnya.'
    },
    {
      'title': 'Larangan',
      'desc': 'Dilarang membawa, mengonsumsi, atau menyimpan minuman keras, narkoba, dan memelihara hewan di dalam kamar.'
    },
    {
      'title': 'Keamanan',
      'desc': 'Penghuni wajib menjaga keamanan barang pribadi. Pihak pengelola tidak bertanggung jawab atas kehilangan barang.'
    },
    {
      'title': 'Kerusakan Fasilitas',
      'desc': 'Kerusakan fasilitas akibat kelalaian penghuni menjadi tanggung jawab penghuni yang bersangkutan.'
    },
    {
      'title': 'Ketenangan',
      'desc': 'Dilarang membuat keributan yang mengganggu penghuni lain, terutama di malam hari.'
    },
    {
      'title': 'Memasak',
      'desc': 'Memasak hanya diperbolehkan di area dapur bersama, bukan di dalam kamar.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F5F3),
      appBar: AppBar(
        title: Text('Syarat & Ketentuan'),
        backgroundColor: Color(0xFF18323A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Icon(Icons.rule, color: Color(0xFF2D9CDB), size: 80),
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  'Syarat & Ketentuan Penghuni Kos',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF18323A),
                    fontFamily: 'Roboto',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 24),
              ...rules.map((rule) => _RuleCard(title: rule['title']!, desc: rule['desc']!)).toList(),
              SizedBox(height: 32),
              Center(
                child: Text(
                  'Dengan tinggal di kos ini, Anda dianggap telah membaca dan menyetujui seluruh syarat & ketentuan di atas.',
                  style: TextStyle(
                    color: Color(0xFF7B7B7B),
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  final String title;
  final String desc;
  const _RuleCard({required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check_circle, color: Color(0xFF2D9CDB), size: 28),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Color(0xFF18323A),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF5A6A73),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}