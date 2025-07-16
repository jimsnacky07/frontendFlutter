import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F5F3), // abu muda
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 380,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 36),
            decoration: BoxDecoration(
              color: Color(0xFFD1D2CD), // abu card
              borderRadius: BorderRadius.circular(48),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Silahkan Login Dulu',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5A6A73),
                    fontFamily: 'Roboto',
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Username',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF7B7B7B),
                        fontFamily: 'Roboto',
                      )),
                ),
                TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF7B7B7B), width: 1.5),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF7B7B7B), width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
                SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Password',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF7B7B7B),
                        fontFamily: 'Roboto',
                      )),
                ),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFB07C7C), width: 1.5),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFB07C7C), width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
                SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(value: false, onChanged: (_) {}),
                    Text('Admin', style: TextStyle(fontFamily: 'Roboto', color: Color(0xFF5A6A73))),
                    SizedBox(width: 32),
                    Checkbox(value: false, onChanged: (_) {}),
                    Text('User', style: TextStyle(fontFamily: 'Roboto', color: Color(0xFF5A6A73))),
                  ],
                ),
                SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF5A6A73),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: Text('Login', style: TextStyle(fontSize: 18, fontFamily: 'Roboto', color: Colors.white)),
                  ),
                ),
                SizedBox(height: 16),
                Text('Lupa Password ?', style: TextStyle(color: Color(0xFFB0B0B0), fontFamily: 'Roboto', fontSize: 15)),
                SizedBox(height: 8),
                Text('Daftar akun baru', style: TextStyle(color: Color(0xFFB0B0B0), fontFamily: 'Roboto', fontSize: 15)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}