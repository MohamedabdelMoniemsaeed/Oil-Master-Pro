import 'package:drift/drift.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../database/database.dart';
import '../../repositories/settings_repository.dart';
import 'service_locator.dart';

class LicenseService {
  static const String salt = "OIL_MASTER_PRO_SECRET";

  // Simple logic: key is md5(shopName + salt)
  static String generateKey(String shopName) {
    var bytes = utf8.encode(shopName + salt);
    return md5.convert(bytes).toString().toUpperCase().substring(0, 16);
  }

  static Future<bool> isActivated() async {
    final settingsRepo = getIt<SettingsRepository>();
    final settings = await settingsRepo.getSettings();
    if (settings == null || settings.licenseKey == null) return false;
    
    // Check if key matches shop name
    return settings.licenseKey == generateKey(settings.shopName);
  }

  static Future<bool> activate(String key) async {
    final settingsRepo = getIt<SettingsRepository>();
    final settings = await settingsRepo.getSettings();
    if (settings == null) return false;

    if (key == generateKey(settings.shopName)) {
      await settingsRepo.updateSettings(settings.copyWith(
        licenseKey: Value(key),
      ));
      return true;
    }
    return false;
  }
}
