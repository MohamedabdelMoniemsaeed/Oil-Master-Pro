import 'package:flutter/material.dart';
import '../../../core/widgets/side_menu.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const SideMenu(),

          Expanded(
            child: Container(
              color: Colors.grey.shade100,
              child: const Center(
                child: Text(
                  "Dashboard",
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}