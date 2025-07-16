import 'package:flutter/material.dart';

class LayoutsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Layouts'),
      ),
      body: Center(
        child: Text(
          'Layouts Page Content',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}