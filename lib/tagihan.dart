import 'package:flutter/material.dart';
import 'api_service.dart';

class TagihanPage extends StatefulWidget {
  @override
  _TagihanPageState createState() => _TagihanPageState();
}

class _TagihanPageState extends State<TagihanPage> {
  List<dynamic> bills = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBills();
  }

  void fetchBills() async {
    try {
      final data = await ApiService().get('tagihan');
      setState(() {
        bills = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching bills: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F5F3),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFDFE3E6), width: 2),
            ),
          ),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Tagihan',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5A6A73),
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ),
      body: Container(
        color: Color(0xFFF6F5F3),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                itemCount: bills.length,
                itemBuilder: (context, index) {
                  final bill = bills[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: Card(
                      color: Colors.white,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Color(0xFFD1D2CD),
                              radius: 32,
                              child: Icon(Icons.receipt, color: Color(0xFF5A6A73), size: 32),
                            ),
                            SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bill ID: ${bill['id'] ?? 'Unknown'}',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF18323A),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Amount: ${bill['amount'] ?? 'Unknown'}',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 16,
                                      color: Color(0xFF5A6A73),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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