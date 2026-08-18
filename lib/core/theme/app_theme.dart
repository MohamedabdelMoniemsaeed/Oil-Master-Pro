import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import '../constants/app_colors.dart';

class AppTheme {
  static FluentThemeData get lightTheme {
    return FluentThemeData(
      brightness: Brightness.light,
      accentColor: material.Colors.blue.toAccentColor(),
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.card,
      fontFamily: 'Cairo',
      typography: const Typography.raw(
        body: TextStyle(fontSize: 18, color: AppColors.grey800), // زيادة الحجم
        title: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.grey900),
        subtitle: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.grey700),
        caption: TextStyle(fontSize: 16, color: AppColors.grey600),
      ),
      visualDensity: material.VisualDensity.standard,
      focusTheme: FocusThemeData(
        glowColor: material.Colors.blue.withValues(alpha: 0.3),
      ),
    );
  }

  static FluentThemeData get darkTheme {
    return FluentThemeData(
      brightness: Brightness.dark,
      accentColor: material.Colors.blue.toAccentColor(),
      scaffoldBackgroundColor: AppColors.darkBackground,
      cardColor: AppColors.darkCard,
      fontFamily: 'Cairo',
      typography: const Typography.raw(
        body: TextStyle(fontSize: 18, color: AppColors.darkText),
        title: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.darkText),
        subtitle: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.darkText),
        caption: TextStyle(fontSize: 16, color: AppColors.grey500),
      ),
      visualDensity: material.VisualDensity.standard,
      focusTheme: FocusThemeData(
        glowColor: material.Colors.blue.withValues(alpha: 0.3),
      ),
    );
  }

  static material.ThemeData get materialLight => material.ThemeData(
        useMaterial3: true,
        fontFamily: 'Cairo',
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: material.ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
      );

  static material.ThemeData get materialDark => material.ThemeData(
        useMaterial3: true,
        fontFamily: 'Cairo',
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.darkBackground,
        colorScheme: material.ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
      );
}
