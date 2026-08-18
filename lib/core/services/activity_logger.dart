import 'package:drift/drift.dart';
import '../../database/database.dart';
import 'service_locator.dart';

class ActivityLogger {
  static Future<void> log({
    required String type,
    required String description,
    int? userId,
    String? userName,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final db = getIt<AppDatabase>();
      await db.into(db.activityLogsTable).insert(
        ActivityLogsTableCompanion.insert(
          actionType: type,
          description: description,
          userId: Value(userId),
          userName: Value(userName),
          metadata: Value(metadata?.toString()),
        ),
      );
    } catch (e) {
      // Fail silently to not break main flow, but ideally use a better logging
      print("Logging error: $e");
    }
  }
}
