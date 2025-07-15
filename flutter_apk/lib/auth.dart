import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auth'),
      ),
      body: Center(
        child: Text(
          'Authentication Page Content',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}