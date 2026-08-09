import 'package:drift/drift.dart';
import '../../database/database.dart';

class ActivityLogger {
  static Future<void> logActivity({
    required String userId,
    required String action,
    required String description,
    String? details,
  }) async {
    try {
      // سجل النشاط في قاعدة البيانات أو ملف
      print('[ACTIVITY] User: $userId | Action: $action | Description: $description | Details: $details');
      // يمكن إضافة حفظ في جدول منفصل لاحقًا
    } catch (e) {
      print('Error logging activity: $e');
    }
  }

  static Future<void> logError({
    required String action,
    required String error,
    String? stackTrace,
  }) async {
    try {
      print('[ERROR] Action: $action | Error: $error | StackTrace: $stackTrace');
    } catch (e) {
      print('Error logging error: $e');
    }
  }

  static Future<void> logSale({
    required int invoiceId,
    required double total,
    required int customerId,
  }) async {
    await logActivity(
      userId: 'system',
      action: 'SALE_CREATED',
      description: 'إنشاء فاتورة بيع جديدة',
      details: 'Invoice ID: $invoiceId, Total: $total, Customer: $customerId',
    );
  }

  static Future<void> logPurchase({
    required int purchaseId,
    required double total,
  }) async {
    await logActivity(
      userId: 'system',
      action: 'PURCHASE_CREATED',
      description: 'إنشاء فاتورة مشتريات جديدة',
      details: 'Purchase ID: $purchaseId, Total: $total',
    );
  }

  static Future<void> logLicenseActivation({
    required String shopName,
    required DateTime expiryDate,
  }) async {
    await logActivity(
      userId: 'system',
      action: 'LICENSE_ACTIVATED',
      description: 'تفعيل الترخيص',
      details: 'Shop: $shopName, Expiry: $expiryDate',
    );
  }
}
