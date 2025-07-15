import 'package:flutter/material.dart';
import 'api_service.dart';

class KeuanganPage extends StatefulWidget {
  @override
  _KeuanganPageState createState() => _KeuanganPageState();
}

class _KeuanganPageState extends State<KeuanganPage> {
  List<dynamic> finances = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFinances();
  }

  void fetchFinances() async {
    try {
      final data = await ApiService().get('keuangan');
      setState(() {
        finances = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching finances: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Keuangan Page'),
        backgroundColor: Colors.orange,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: finances.length,
              itemBuilder: (context, index) {
                final finance = finances[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(finance['description'] ?? 'No Description'),
                    subtitle: Text('Amount: ${finance['amount'] ?? 'Unknown'}'),
                  ),
                );
              },
            ),
    );
  }
}