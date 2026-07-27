import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/dashboard/screens/dashboard_screen.dart';

class CarOilShopApp extends StatelessWidget {
  const CarOilShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Car Oil Shop',
      theme: AppTheme.lightTheme,
      home: const DashboardScreen(),
    );
  }
}