import 'package:drift/drift.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../database/database.dart';
import '../../repositories/settings_repository.dart';
import 'service_locator.dart';

class LicenseValidationResult {
  final bool isValid;
  final String? message;
  final DateTime? expiryDate;

  const LicenseValidationResult({required this.isValid, this.message, this.expiryDate});
}

class LicenseService {
  static const String salt = "OIL_MASTER_PRO_SECRET";
  static const String demoLicenseKey = "OIL-ZEIT-2026";
  static const Duration licenseDuration = Duration(days: 365);
  static const String payloadSeparator = '|';

  static String generateKey(String shopName) {
    final normalized = shopName.trim().toLowerCase();

    if (normalized.contains('زيت') || normalized.contains('zait')) {
      return demoLicenseKey;
    }

    final bytes = utf8.encode(shopName + salt);
    return md5.convert(bytes).toString().toUpperCase().substring(0, 16);
  }

  static String buildLicensePayload(String key, String deviceId, DateTime expiryDate) {
    final normalizedKey = key.trim().toUpperCase();
    final normalizedDeviceId = deviceId.trim();
    final expiryValue = expiryDate.toUtc().toIso8601String();
    return '$normalizedKey$payloadSeparator$normalizedDeviceId$payloadSeparator$expiryValue';
  }

  static LicenseValidationResult validateStoredLicense(
    String? storedLicense, {
    required String currentDeviceId,
    required DateTime now,
    required String expectedKey,
  }) {
    if (storedLicense == null || storedLicense.trim().isEmpty) {
      return const LicenseValidationResult(isValid: false, message: 'No license found');
    }

    final parts = storedLicense.split(payloadSeparator);
    if (parts.length != 3) {
      return const LicenseValidationResult(isValid: false, message: 'Invalid license format');
    }

    final key = parts[0].trim().toUpperCase();
    final deviceId = parts[1].trim();
    final expiryDate = DateTime.tryParse(parts[2].trim());

    if (key != expectedKey.toUpperCase()) {
      return const LicenseValidationResult(isValid: false, message: 'Invalid key');
    }

    if (deviceId != currentDeviceId.trim()) {
      return const LicenseValidationResult(isValid: false, message: 'License is bound to another device');
    }

    if (expiryDate == null || expiryDate.isBefore(now)) {
      return const LicenseValidationResult(isValid: false, message: 'License has expired');
    }

    return LicenseValidationResult(
      isValid: true,
      message: 'License is valid',
      expiryDate: expiryDate,
    );
  }

  static Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    const storageKey = 'oil_master_device_id';
    final existing = prefs.getString(storageKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final generated = 'device-${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setString(storageKey, generated);
    return generated;
  }

  static Future<bool> isActivated() async {
    final settingsRepo = getIt<SettingsRepository>();
    final settings = await settingsRepo.getSettings();
    if (settings == null || settings.licenseKey == null || settings.expiryDate == null) {
      return false;
    }

    final expectedKey = generateKey(settings.shopName).toUpperCase();
    final deviceId = await _getDeviceId();
    final result = validateStoredLicense(
      settings.licenseKey,
      currentDeviceId: deviceId,
      now: DateTime.now(),
      expectedKey: expectedKey,
    );

    return result.isValid;
  }

  static Future<bool> activate(String key) async {
    final settingsRepo = getIt<SettingsRepository>();
    final settings = await settingsRepo.getSettings();
    if (settings == null) return false;

    final expectedKey = generateKey(settings.shopName).toUpperCase();
    final enteredKey = key.trim().toUpperCase();
    if (enteredKey != expectedKey) {
      return false;
    }

    final deviceId = await _getDeviceId();
    final expiryDate = DateTime.now().add(licenseDuration);
    final payload = buildLicensePayload(key.trim(), deviceId, expiryDate);

    await settingsRepo.updateSettings(
      settings.copyWith(
        licenseKey: Value(payload),
        expiryDate: Value(expiryDate),
      ),
    );
    return true;
  }
}
