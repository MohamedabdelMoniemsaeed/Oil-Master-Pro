import 'package:drift/drift.dart';

class LicenseNotificationService {
  static const Duration warningDuration = Duration(days: 30);
  static const Duration criticalDuration = Duration(days: 7);

  static String getLicenseStatus(DateTime? expiryDate) {
    if (expiryDate == null) return 'غير مفعّل';

    final daysLeft = expiryDate.difference(DateTime.now()).inDays;

    if (daysLeft > 30) return 'صالح';
    if (daysLeft > 7) return 'ينتهي قريبًا';
    if (daysLeft > 0) return 'حرج';
    return 'منتهي الصلاحية';
  }

  static String getLicenseMessage(DateTime? expiryDate) {
    if (expiryDate == null) return 'الترخيص غير مفعّل. يرجى تفعيله من الإعدادات.';

    final daysLeft = expiryDate.difference(DateTime.now()).inDays;

    if (daysLeft > 30) {
      return 'الترخيص صالح حتى ${expiryDate.toLocal().toString().split(' ')[0]}';
    } else if (daysLeft > 7) {
      return 'تحذير: الترخيص ينتهي خلال $daysLeft أيام. يرجى التجديد قريبًا.';
    } else if (daysLeft > 0) {
      return 'تنبيه حرج: الترخيص سينتهي خلال $daysLeft أيام فقط!';
    } else {
      return 'الترخيص منتهي الصلاحية. يرجى التجديد فورًا.';
    }
  }

  static bool shouldShowWarning(DateTime? expiryDate) {
    if (expiryDate == null) return true;
    final daysLeft = expiryDate.difference(DateTime.now()).inDays;
    return daysLeft <= 30;
  }

  static bool isCritical(DateTime? expiryDate) {
    if (expiryDate == null) return true;
    final daysLeft = expiryDate.difference(DateTime.now()).inDays;
    return daysLeft <= 7;
  }

  static bool isExpired(DateTime? expiryDate) {
    if (expiryDate == null) return true;
    return DateTime.now().isAfter(expiryDate);
  }
}
