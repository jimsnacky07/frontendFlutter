import 'package:flutter/material.dart';
import 'api_service.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  String welcomeMessage = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWelcomeMessage();
  }

  void fetchWelcomeMessage() async {
    try {
      final data = await ApiService().get('welcome');
      setState(() {
        welcomeMessage = data['message'] ?? 'Welcome!';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching welcome message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome Page'),
        backgroundColor: Colors.blueGrey,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Text(
                welcomeMessage,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
    );
  }
}