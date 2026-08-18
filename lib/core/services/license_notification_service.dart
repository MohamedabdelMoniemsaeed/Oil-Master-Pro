import 'license_service.dart';

class LicenseNotificationService {
  static const int warningDays = 30;
  static const int criticalDays = 7;

  static String getLicenseStatus(DateTime? expiryDate) {
    if (expiryDate == null) return 'غير مفعّل';
    final daysLeft = expiryDate.difference(DateTime.now()).inDays;
    if (daysLeft > warningDays) return 'صالح';
    if (daysLeft > criticalDays) return 'ينتهي قريبًا';
    if (daysLeft >= 0) return 'حرج';
    return 'منتهي الصلاحية';
  }

  static String getLicenseMessage(DateTime? expiryDate, {LicenseType type = LicenseType.none}) {
    if (expiryDate == null) return 'الترخيص غير مفعّل. يرجى تفعيله من الإعدادات.';

    final daysLeft = expiryDate.difference(DateTime.now()).inDays;
    final isTrial = type == LicenseType.trial;

    if (daysLeft > warningDays) {
      return '${isTrial ? "التجربة المجانية" : "الترخيص"} صالحة حتى ${expiryDate.toLocal().toString().split(' ')[0]}';
    } else if (daysLeft > criticalDays) {
      return 'تحذير: ${isTrial ? "التجربة" : "الترخيص"} ينتهي خلال $daysLeft أيام. يرجى التفعيل للاستمرار.';
    } else if (daysLeft >= 0) {
      return 'تنبيه حرج: ${isTrial ? "التجربة" : "الترخيص"} ستنتهي خلال $daysLeft أيام فقط!';
    } else {
      return '${isTrial ? "انتهت الفترة التجريبية" : "الترخيص منتهي الصلاحية"}. يرجى التفعيل فورًا.';
    }
  }

  static bool shouldShowWarning(DateTime? expiryDate) {
    if (expiryDate == null) return true;
    final daysLeft = expiryDate.difference(DateTime.now()).inDays;
    return daysLeft <= warningDays;
  }

  static bool isCritical(DateTime? expiryDate) {
    if (expiryDate == null) return true;
    final daysLeft = expiryDate.difference(DateTime.now()).inDays;
    return daysLeft <= criticalDays;
  }

  static bool isExpired(DateTime? expiryDate) {
    if (expiryDate == null) return true;
    return DateTime.now().isAfter(expiryDate);
  }
}
