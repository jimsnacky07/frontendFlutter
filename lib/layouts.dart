import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LayoutsPage extends StatelessWidget {
  void openWhatsApp(BuildContext context) async {
    final phone = '6283800656955'; // 62 untuk Indonesia
    final message = Uri.encodeComponent('Halo, saya ingin bertanya tentang kos.');
    
    // Coba beberapa format URL WhatsApp
    final urls = [
      Uri.parse('https://wa.me/$phone?text=$message'),
      Uri.parse('whatsapp://send?phone=$phone&text=$message'),
      Uri.parse('https://api.whatsapp.com/send?phone=$phone&text=$message'),
    ];
    
    bool success = false;
    
    for (Uri url in urls) {
      try {
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
          success = true;
          break;
        }
      } catch (e) {
        print('Failed to launch URL: $url - $e');
        continue;
      }
    }
    
    if (!success) {
      // Jika semua gagal, tampilkan dialog dengan opsi manual
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Tidak dapat membuka WhatsApp'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Silakan pilih salah satu opsi:'),
              SizedBox(height: 16),
              Text('Nomor WhatsApp: 0838-0065-6955'),
              SizedBox(height: 8),
              Text('Pesan: Halo, saya ingin bertanya tentang kos.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Tutup'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Coba buka browser dengan WhatsApp Web
                launchUrl(
                  Uri.parse('https://web.whatsapp.com/send?phone=$phone&text=$message'),
                  mode: LaunchMode.externalApplication,
                );
              },
              child: Text('Buka WhatsApp Web'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bantuan'),
        backgroundColor: Color(0xFF18323A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.help_outline, color: Color(0xFF2D9CDB), size: 80),
              SizedBox(height: 24),
              Text(
                'Butuh bantuan atau ingin bertanya seputar kos?\nSilakan hubungi penjaga kos melalui WhatsApp.',
                style: TextStyle(fontSize: 18, color: Color(0xFF18323A), fontFamily: 'Roboto'),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => openWhatsApp(context),
                icon: Icon(Icons.chat, color: Colors.white),
                label: Text('Hubungi Penjaga Kos via WhatsApp'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              SizedBox(height: 32),
              Text(
                'Nomor WhatsApp: 0838-0065-6955',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF5A6A73),
                  fontFamily: 'Roboto',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}