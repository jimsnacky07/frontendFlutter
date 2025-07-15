import 'package:flutter/material.dart';
import 'api_service.dart';

class PenghuniPage extends StatefulWidget {
  @override
  _PenghuniPageState createState() => _PenghuniPageState();
}

class _PenghuniPageState extends State<PenghuniPage> {
  List<dynamic> residents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchResidents();
  }

  void fetchResidents() async {
    try {
      final data = await ApiService().get('penghuni');
      setState(() {
        residents = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching residents: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Penghuni Page'),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: residents.length,
              itemBuilder: (context, index) {
                final resident = residents[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(resident['name'] ?? 'No Name'),
                    subtitle: Text('Room: ${resident['room'] ?? 'Unknown'}'),
                  ),
                );
              },
            ),
    );
  }
}