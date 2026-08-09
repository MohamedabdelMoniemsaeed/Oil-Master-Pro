import 'dart:io';
import 'package:path/path.dart' as p;

void main() async {
  // 1. تحديد مسار مجلد الـ Release
  final releaseDir = Directory('build/windows/x64/runner/Release');
  
  if (!await releaseDir.exists()) {
    print('Error: Release folder not found. Please run "flutter build windows" first.');
    return;
  }

  // 2. قائمة الملفات المطلوبة من النظام
  final system32 = 'C:\\Windows\\System32';
  final requiredDlls = [
    'vcruntime140.dll',
    'vcruntime140_1.dll',
    'msvcp140.dll',
  ];

  print('Starting to bundle system DLLs...');

  for (var dll in requiredDlls) {
    final source = File(p.join(system32, dll));
    final destination = File(p.join(releaseDir.path, dll));

    if (await source.exists()) {
      await source.copy(destination.path);
      print('✅ Copied: $dll');
    } else {
      print('❌ Warning: $dll not found in System32. You might need to install Visual C++ Redistributable.');
    }
  }

  print('\nDone! Now you can send the whole "Release" folder to your client.');
}
