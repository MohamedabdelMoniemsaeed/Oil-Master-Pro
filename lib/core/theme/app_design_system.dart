import 'package:fluent_ui/fluent_ui.dart';
import '../constants/app_colors.dart';

class AppDesignSystem {
  // Border Radius
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusExtraLarge = 16.0;

  static BorderRadius get borderSmall => BorderRadius.circular(radiusSmall);
  static BorderRadius get borderMedium => BorderRadius.circular(radiusMedium);
  static BorderRadius get borderLarge => BorderRadius.circular(radiusLarge);
  static BorderRadius get borderExtraLarge => BorderRadius.circular(radiusExtraLarge);

  // Shadows (3D Depth)
  static List<BoxShadow> get shadowLow => [
        BoxShadow(
          color: AppColors.shadowLight,
          offset: const Offset(0, 2),
          blurRadius: 4,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get shadowMedium => [
        BoxShadow(
          color: AppColors.shadowLight,
          offset: const Offset(0, 4),
          blurRadius: 10,
          spreadRadius: -2,
        ),
      ];

  static List<BoxShadow> get shadowHigh => [
        BoxShadow(
          color: AppColors.shadowDark,
          offset: const Offset(0, 10),
          blurRadius: 20,
          spreadRadius: -5,
        ),
      ];

  // Subtle 3D Depth Decoration
  static BoxDecoration cardDecoration({bool isHovered = false, bool isDarkMode = false}) {
    return BoxDecoration(
      color: isDarkMode ? AppColors.darkCard : AppColors.card,
      borderRadius: borderMedium,
      boxShadow: isHovered ? shadowHigh : shadowMedium,
      border: Border.all(
        color: isDarkMode ? AppColors.grey800 : AppColors.grey200,
        width: 0.5,
      ),
    );
  }

  // Linear Gradients
  static Gradient get primaryGradient => const LinearGradient(
        colors: [AppColors.primary, AppColors.secondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // Spacing
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingExtraLarge = 32.0;
}
