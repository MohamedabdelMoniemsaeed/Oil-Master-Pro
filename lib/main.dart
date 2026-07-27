import 'package:flutter/material.dart';

void main() {
  runApp(const CarOilShopApp());
}

class CarOilShopApp extends StatelessWidget {
  const CarOilShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Oil Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'Car Oil Shop',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}