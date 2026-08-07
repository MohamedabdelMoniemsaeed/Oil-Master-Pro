import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

class BackupService {
  static Future<bool> createBackup() async {
    try {
      final appDir = await getApplicationSupportDirectory();
      final dbFile = File(p.join(appDir.path, 'oilmaster.db'));

      if (!await dbFile.exists()) return false;

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'اختر مكان حفظ النسخة الاحتياطية',
        fileName: 'oilmaster_backup_${DateTime.now().millisecondsSinceEpoch}.db',
      );

      if (outputFile != null) {
        await dbFile.copy(outputFile);
        return true;
      }
      return false;
    } catch (e) {
      print('Backup error: $e');
      return false;
    }
  }

  static Future<bool> restoreBackup() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null) {
        final backupFile = File(result.files.single.path!);
        final appDir = await getApplicationSupportDirectory();
        final dbFile = File(p.join(appDir.path, 'oilmaster.db'));

        // Close DB connections before overwriting might be needed in a real app
        // For simplicity here, we assume the app might need a restart
        await backupFile.copy(dbFile.path);
        return true;
      }
      return false;
    } catch (e) {
      print('Restore error: $e');
      return false;
    }
  }
}
