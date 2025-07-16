import 'package:flutter/material.dart';
import 'api_service.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<dynamic> admins = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAdmins();
  }

  void fetchAdmins() async {
    try {
      final data = await ApiService().get('admin');
      setState(() {
        admins = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching admins: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Page',
            style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Container(
        color: Colors.grey[200],
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: admins.length,
                itemBuilder: (context, index) {
                  final admin = admins[index];
                  return Card(
                    margin: EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(
                        admin['name'] ?? 'No Name',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        admin['email'] ?? 'No Email',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          color: Colors.black54,
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