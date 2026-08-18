import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sqlite3/sqlite3.dart';
import '../../database/database.dart';
import 'service_locator.dart';
import 'activity_logger.dart';
import 'permission_service.dart';

class BackupService {
  static Future<bool> createBackup({UsersTableData? user}) async {
    if (!PermissionService.canBackup(user)) {
      throw Exception("ليس لديك صلاحية لإنشاء نسخة احتياطية.");
    }

    try {
      final db = getIt<AppDatabase>();
      
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'اختر مكان حفظ النسخة الاحتياطية',
        fileName: 'CASHIER_PRO_Backup_${DateTime.now().toString().replaceAll(':', '-').split('.')[0].replaceAll(' ', '_')}.db',
      );

      if (outputPath == null) return false;

      bool success = false;
      try {
        await db.customStatement("VACUUM INTO '$outputPath'");
        success = true;
      } catch (e) {
        final appDir = await getApplicationSupportDirectory();
        final dbFile = File(p.join(appDir.path, 'cashier_pro.db'));
        if (await dbFile.exists()) {
          await dbFile.copy(outputPath);
          success = true;
        }
      }

      if (success) {
        ActivityLogger.log(
          type: 'BACKUP_CREATE',
          description: 'تم إنشاء نسخة احتياطية بنجاح في: $outputPath',
          userId: user?.id,
          userName: user?.fullName,
        );
      }
      
      return success;
    } catch (e) {
      print('Backup error: $e');
      return false;
    }
  }

  static Future<bool> restoreBackup({UsersTableData? user}) async {
    if (!PermissionService.canRestore(user)) {
      ActivityLogger.log(
        type: 'RESTORE_DENIED',
        description: 'محاولة استعادة مرفوضة: صلاحيات غير كافية',
        userId: user?.id,
        userName: user?.fullName,
        metadata: {'reason': 'Insufficient Permission'},
      );
      throw Exception("ليس لديك صلاحية لاستعادة النسخ الاحتياطية.");
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        dialogTitle: 'اختر ملف النسخة الاحتياطية للاستعادة',
      );

      if (result == null || result.files.single.path == null) return false;

      final backupFile = File(result.files.single.path!);
      final appDir = await getApplicationSupportDirectory();
      final dbPath = p.join(appDir.path, 'cashier_pro.db');
      final dbFile = File(dbPath);

      // 1. SQLite Signature Check
      if (!await _isValidSqlite(backupFile)) {
        throw Exception("الملف المختار ليس قاعدة بيانات صالحة");
      }

      // 2. Deep Integrity Check using sqlite3 library directly (offline check)
      if (!_isDatabaseIntact(backupFile.path)) {
        throw Exception("ملف النسخة الاحتياطية تالف (Integrity Check Failed)");
      }

      // 3. Emergency Backup of current DB
      final emergencyPath = p.join(appDir.path, 'Emergency_Backup_Before_Restore.db');
      if (await dbFile.exists()) {
        await dbFile.copy(emergencyPath);
      }

      // 4. Close and overwrite
      final db = getIt<AppDatabase>();
      await db.close();

      try {
        await backupFile.copy(dbPath);
        
        final walFile = File('$dbPath-wal');
        final shmFile = File('$dbPath-shm');
        if (await walFile.exists()) await walFile.delete();
        if (await shmFile.exists()) await shmFile.delete();

        // Note: Logging here might fail as DB is closed, but it's okay since we restart
        return true;
      } catch (e) {
        if (await File(emergencyPath).exists()) {
          await File(emergencyPath).copy(dbPath);
        }
        rethrow;
      }
    } catch (e) {
      print('Restore error: $e');
      rethrow;
    }
  }

  static Future<bool> _isValidSqlite(File file) async {
    try {
      if (!await file.exists()) return false;
      final bytes = await file.openRead(0, 16).first;
      if (bytes.length < 16) return false;
      return String.fromCharCodes(bytes).startsWith("SQLite format 3");
    } catch (e) {
      return false;
    }
  }

  static bool _isDatabaseIntact(String path) {
    try {
      final db = sqlite3.open(path);
      try {
        final result = db.select('PRAGMA integrity_check').first;
        final status = result.columnAt(0) as String;
        return status.toLowerCase() == 'ok';
      } finally {
        db.dispose();
      }
    } catch (e) {
      return false;
    }
  }
}
