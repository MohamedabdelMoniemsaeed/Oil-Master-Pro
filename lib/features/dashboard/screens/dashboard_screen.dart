import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Car Oil Shop"),
      ),
      drawer: Drawer(
        child: ListView(
          children: const [
            DrawerHeader(
              child: Text(
                "Car Oil Shop",
                style: TextStyle(fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text("Dashboard"),
            ),
            ListTile(
              leading: Icon(Icons.inventory),
              title: Text("Products"),
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text("Customers"),
            ),
            ListTile(
              leading: Icon(Icons.directions_car),
              title: Text("Cars"),
            ),
            ListTile(
              leading: Icon(Icons.receipt_long),
              title: Text("Invoices"),
            ),
            ListTile(
              leading: Icon(Icons.bar_chart),
              title: Text("Reports"),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text(
          "Dashboard",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}