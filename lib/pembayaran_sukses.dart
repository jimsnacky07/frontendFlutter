import 'package:flutter/material.dart';

class PembayaranSuksesPage extends StatelessWidget {
  final String message;
  final Map<String, dynamic>? detail;
  PembayaranSuksesPage({this.message = "Pembayaran berhasil!", this.detail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sukses")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 80),
            SizedBox(height: 24),
            Text(message, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
            if (detail != null) ...[
              SizedBox(height: 16),
              Text("Detail Pembayaran:", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ...detail!.entries.map((e) => Text("${e.key}: ${e.value}")),
            ],
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Kembali"),
            ),
          ],
        ),
      ),
    );
  }
} 