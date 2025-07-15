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
        title: Text('Admin Page'),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: admins.length,
              itemBuilder: (context, index) {
                final admin = admins[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(admin['name'] ?? 'No Name'),
                    subtitle: Text(admin['email'] ?? 'No Email'),
                  ),
                );
              },
            ),
    );
  }
}