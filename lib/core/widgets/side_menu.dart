import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      color: const Color(0xff1565C0),
      child: Column(
        children: [
          const SizedBox(height: 30),

          const Icon(
            Icons.shopping_cart,
            color: Colors.white,
            size: 70,
          ),

          const SizedBox(height: 15),

          const Text(
            "CASHIER PRO",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 40),

          buildItem(Icons.dashboard, "Dashboard"),
          buildItem(Icons.inventory_2, "Products"),
          buildItem(Icons.people, "Customers"),
          buildItem(Icons.receipt_long, "Sales"),
          buildItem(Icons.shopping_cart, "Purchases"),
          buildItem(Icons.bar_chart, "Reports"),
          buildItem(Icons.settings, "Settings"),

          const Spacer(),

          buildItem(Icons.logout, "Logout"),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget buildItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}