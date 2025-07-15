import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Page'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to the Dashboard!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              children: [
                DashboardCard(title: 'Admin', route: '/admin', icon: Icons.admin_panel_settings),
                DashboardCard(title: 'Kamar', route: '/kamar', icon: Icons.bed),
                DashboardCard(title: 'Keuangan', route: '/keuangan', icon: Icons.attach_money),
                DashboardCard(title: 'Laporan', route: '/laporan', icon: Icons.report),
                DashboardCard(title: 'Penghuni', route: '/penghuni', icon: Icons.people),
                DashboardCard(title: 'Tagihan', route: '/tagihan', icon: Icons.receipt),
                DashboardCard(title: 'Welcome', route: '/welcome', icon: Icons.home),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String route;
  final IconData icon;

  DashboardCard({required this.title, required this.route, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.blue),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}