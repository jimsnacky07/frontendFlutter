import 'package:flutter/material.dart';
import 'admin.dart';
import 'dashboard.dart';
import 'kamar.dart';
import 'keuangan.dart';
import 'laporan.dart';
import 'penghuni.dart';
import 'tagihan.dart';
import 'welcome.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Laravel Mirror',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainLayout(),
    );
  }
}

class MainLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F5F3),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFDFE3E6), width: 2),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo kiri
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Color(0xFFD1D2CD),
                    radius: 24,
                    child: Icon(Icons.home, color: Color(0xFF5A6A73), size: 32),
                  ),
                ],
              ),
              // Menu tengah
              Row(
                children: [
                  _NavButton(label: 'Beranda', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardPage()));
                  }),
                  SizedBox(width: 24),
                  _NavButton(label: 'Kamar', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => KamarPage()));
                  }),
                  SizedBox(width: 24),
                  _NavButton(label: 'Syarat & Ketentuan', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => WelcomePage()));
                  }),
                ],
              ),
              // Kanan: Bantuan & Logout
              Row(
                children: [
                  Text('Bantuan ?', style: TextStyle(color: Color(0xFF5A6A73), fontSize: 16, fontFamily: 'Roboto')),
                  SizedBox(width: 12),
                  Container(
                    height: 36,
                    child: VerticalDivider(color: Color(0xFF5A6A73)),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.person, size: 18, color: Colors.white),
                    label: Text('Log Out', style: TextStyle(color: Colors.white, fontFamily: 'Roboto')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF18323A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: DashboardPage(),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NavButton({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Text(
          label,
          style: TextStyle(
            color: Color(0xFF18323A),
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
