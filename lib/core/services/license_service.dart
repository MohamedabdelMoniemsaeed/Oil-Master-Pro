import 'package:drift/drift.dart' show Value;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cryptography/cryptography.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../database/database.dart';
import '../../repositories/settings_repository.dart';
import 'service_locator.dart';

enum LicenseType { trial, full, expired, none }

class AppLicenseInfo {
  final LicenseType type;
  final String status;
  final String shopName;
  final String customerName;
  final String licenseId;
  final String deviceId;
  final DateTime? startDate;
  final DateTime? expiryDate;
  final int daysRemaining;
  final bool isVerified;
  
  // Diagnostic Info
  final String? debugLog;

  AppLicenseInfo({
    required this.type,
    required this.status,
    required this.shopName,
    this.customerName = "N/A",
    this.licenseId = "N/A",
    required this.deviceId,
    this.startDate,
    this.expiryDate,
    required this.daysRemaining,
    this.isVerified = false,
    this.debugLog,
  });

  String get typeText {
    switch (type) {
      case LicenseType.trial: return "نسخة تجريبية (Trial)";
      case LicenseType.full: return "ترخيص كامل (Full License)";
      case LicenseType.expired: return "منتهي الصلاحية (Expired)";
      case LicenseType.none: return "غير مفعل (Not Activated)";
    }
  }
}

class LicenseService {
  // THE MASTER PUBLIC KEY (EXACTLY MATCHES GENERATOR DERIVATION)
  // Derived from: "CASHIER_PRO_OFFLINE_SECURE_SEED_V1_2026_MASTER" (First 32 bytes)
  static const String _publicKeyBase64 = "vb49i9BNYrX5vc9Kz6jV34v3AUnPYZPM-vzf9rXIUdM=";
  
  static const String trialPrefix = "TRIAL";
  static const String licenseFormatPrefix = "CP1";
  static const Duration trialDuration = Duration(days: 30);

  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    const storageKey = 'cashier_pro_v1_device_id';
    String? existing = prefs.getString(storageKey);
    if (existing != null && existing.isNotEmpty) return existing;

    String hardwareId = "UNKNOWN";
    try {
      if (Platform.isWindows) {
        final result = await Process.run('wmic', ['csproduct', 'get', 'uuid']);
        final stdout = result.stdout.toString();
        final lines = stdout.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty && l.toLowerCase() != 'uuid').toList();
        if (lines.isNotEmpty) {
          hardwareId = lines.first.toUpperCase();
        }
      }
    } catch (e) {
      hardwareId = 'GEN-${DateTime.now().millisecondsSinceEpoch}';
    }
    
    if (hardwareId == "UNKNOWN" || hardwareId.isEmpty) {
      hardwareId = 'GEN-${DateTime.now().millisecondsSinceEpoch}';
    }

    await prefs.setString(storageKey, hardwareId);
    return hardwareId;
  }

  static Future<bool> isActivated() async {
    final info = await getLicenseInfo();
    
    // Offline Clock Rollback Protection
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final lastRunMillis = prefs.getInt('last_known_valid_time') ?? 0;
    final lastRun = DateTime.fromMillisecondsSinceEpoch(lastRunMillis);
    
    if (now.isBefore(lastRun.subtract(const Duration(minutes: 5)))) {
      debugPrint("Clock Rollback Detected!");
      return false; 
    }
    await prefs.setInt('last_known_valid_time', now.millisecondsSinceEpoch);

    if (info.type == LicenseType.none) {
      final settingsRepo = getIt<SettingsRepository>();
      final settings = await settingsRepo.getSettings();
      if (settings == null || settings.shopName.isEmpty) return true;
      return false;
    }

    return info.isVerified && info.status == "Active";
  }

  static Future<AppLicenseInfo> getLicenseInfo() async {
    final settingsRepo = getIt<SettingsRepository>();
    final settings = await settingsRepo.getSettings();
    final deviceId = (await getDeviceId()).toUpperCase();
    
    if (settings == null || settings.licenseKey == null) {
      return AppLicenseInfo(
        type: LicenseType.none,
        status: "Inactive",
        shopName: settings?.shopName ?? "N/A",
        deviceId: deviceId,
        daysRemaining: 0,
      );
    }

    return await verifyKeyLocally(settings.licenseKey!);
  }

  static Future<bool> activate(String enteredKey) async {
    try {
      debugPrint("--- ACTIVATION PROCESS START ---");
      final info = await verifyKeyLocally(enteredKey);
      
      if (info.type == LicenseType.none || !info.isVerified) {
        debugPrint("Activation aborted: Verification failed. Status: ${info.status}");
        return false;
      }
      
      if (info.status != "Active") {
        debugPrint("Activation aborted: License not active. Status: ${info.status}");
        return false;
      }

      final settingsRepo = getIt<SettingsRepository>();
      final settings = await settingsRepo.getSettings();
      
      final String cleanKey = enteredKey.trim();
      final DateTime? expiry = info.expiryDate;
      
      if (settings == null) {
        debugPrint("Settings row not found. Creating first row...");
        final id = await settingsRepo.saveSettings(
          SettingsTableCompanion.insert(
            shopName: const Value("CASHIER PRO SHOP"),
            licenseKey: Value(cleanKey),
            expiryDate: Value(expiry),
            isFirstRun: const Value(false),
          ),
        );
        debugPrint("Activation Success: Created initial settings with ID: $id");
        return true;
      }

      debugPrint("Updating existing settings (ID: ${settings.id})...");
      final success = await settingsRepo.updateSettings(
        settings.copyWith(
          licenseKey: Value(cleanKey),
          expiryDate: Value(expiry),
        ),
      );
      
      if (success) {
        debugPrint("Activation Success: Updated settings row.");
        // Double Check
        final check = await settingsRepo.getSettings();
        if (check?.licenseKey == cleanKey) {
          debugPrint("Double Check: PASS (Key matches in DB)");
          return true;
        } else {
          debugPrint("Double Check: FAIL (Key mismatch after save!)");
          return false;
        }
      } else {
        debugPrint("Activation FAILED: Database update returned false.");
        return false;
      }

    } catch (e, stack) {
      debugPrint("FATAL ACTIVATION ERROR: $e");
      debugPrint("STACK TRACE: $stack");
      // Specific error for UI
      rethrow;
    }
  }

  static Future<AppLicenseInfo> verifyKeyLocally(String key) async {
    final List<String> logs = [];
    void log(String msg) {
      logs.add(msg);
      debugPrint(msg);
    }

    log("--- START LICENSE VERIFICATION ---");
    final String trimmedKey = key.trim();
    final deviceId = (await getDeviceId()).toUpperCase();
    log("1. Device HWID: $deviceId");

    if (!trimmedKey.startsWith(licenseFormatPrefix)) {
       log("2. Format Check: FAIL (Does not start with $licenseFormatPrefix)");
       return _errorInfo("Invalid Format", deviceId, logs.join("\n"));
    }
    log("2. Format Check: PASS");

    final parts = trimmedKey.split('.');
    log("3. Parts Count: ${parts.length}");
    if (parts.length != 3) {
      log("3. Format Check: FAIL (Expected 3 parts)");
      return _errorInfo("Invalid Parts", deviceId, logs.join("\n"));
    }

    try {
      // UNIFIED BASE64URL DECODING WITH PADDING SUPPORT
      Uint8List decodeSafe(String input) {
        String p = input;
        while (p.length % 4 != 0) { p += '='; }
        // Try Base64Url first (standard)
        try {
          return base64Url.decode(p);
        } catch (_) {
          // Fallback to standard Base64
          return base64.decode(p);
        }
      }

      final payloadBase64 = parts[1];
      final signatureBase64 = parts[2];
      
      final payloadBytes = decodeSafe(payloadBase64);
      log("4. Payload Decode: PASS (${payloadBytes.length} bytes)");

      final signatureBytes = decodeSafe(signatureBase64);
      log("5. Signature Decode: PASS (${signatureBytes.length} bytes)");

      final String payloadJson = utf8.decode(payloadBytes);
      final Map<String, dynamic> data = jsonDecode(payloadJson);
      log("6. JSON Parse: PASS");

      final algorithm = Ed25519();
      final pubKeyBytes = decodeSafe(_publicKeyBase64);
      log("7. Public Key Match Check: ${_publicKeyBase64 == 'vb49i9BNYrX5vc9Kz6jV34v3AUnPYZPM-vzf9rXIUdM=' ? 'MATCH' : 'MISMATCH'}");
      log("7. Embedded PK: $_publicKeyBase64");

      final publicKey = SimplePublicKey(pubKeyBytes, type: KeyPairType.ed25519);
      
      final isSignatureValid = await algorithm.verify(
        payloadBytes,
        signature: Signature(signatureBytes, publicKey: publicKey),
      );

      if (!isSignatureValid) {
        log("8. Digital Signature: INVALID (Verification Failed)");
        return _errorInfo("Signature Verification Failed", deviceId, logs.join("\n"));
      }
      log("8. Digital Signature: VALID");

      final String licensedProd = data['product'] ?? "";
      final String licensedHWID = (data['hardwareId'] ?? "").toString().trim().toUpperCase();
      final DateTime expiry = DateTime.parse(data['expiresAt']);
      final now = DateTime.now();

      log("9. Product: $licensedProd (Expected: CASHIER_PRO)");
      log("10. Licensed HWID: $licensedHWID");
      log("11. Expiry Date: $expiry");

      if (licensedProd != "CASHIER_PRO") {
        log("Result: Product Mismatch");
        return _errorInfo("Product Mismatch", deviceId, logs.join("\n"));
      }

      if (licensedHWID != deviceId) {
        log("Result: Hardware ID Mismatch");
        return _errorInfo("Hardware ID Mismatch", deviceId, logs.join("\n"));
      }

      if (expiry.isBefore(now)) {
        log("Result: License Expired");
        return AppLicenseInfo(
          type: LicenseType.expired,
          status: "Expired",
          shopName: data['shop'] ?? "N/A",
          customerName: data['customer'] ?? "N/A",
          licenseId: data['licenseId'] ?? "N/A",
          deviceId: deviceId,
          startDate: DateTime.tryParse(data['issuedAt'] ?? ""),
          expiryDate: expiry,
          daysRemaining: 0,
          isVerified: true,
          debugLog: logs.join("\n"),
        );
      }

      final diff = expiry.difference(now).inDays;
      log("--- VERIFICATION SUCCESSFUL ---");
      
      return AppLicenseInfo(
        type: _parseType(data['type']),
        status: "Active",
        shopName: data['shop'] ?? "N/A",
        customerName: data['customer'] ?? "N/A",
        licenseId: data['licenseId'] ?? "N/A",
        deviceId: deviceId,
        startDate: DateTime.tryParse(data['issuedAt'] ?? ""),
        expiryDate: expiry,
        daysRemaining: diff < 0 ? 0 : diff,
        isVerified: true,
        debugLog: logs.join("\n"),
      );

    } catch (e) {
      log("PROCESS ERROR: $e");
      return _errorInfo("Execution Error: $e", deviceId, logs.join("\n"));
    }
  }

  static AppLicenseInfo _errorInfo(String status, String deviceId, String logs) {
    return AppLicenseInfo(
      type: LicenseType.none,
      status: status,
      shopName: "N/A",
      deviceId: deviceId,
      daysRemaining: 0,
      isVerified: false,
      debugLog: logs,
    );
  }

  static LicenseType _parseType(String? type) {
    if (type == 'TRIAL') return LicenseType.trial;
    return LicenseType.full;
  }

  static Future<bool> canStartTrial() async {
    final prefs = await SharedPreferences.getInstance();
    final deviceId = await getDeviceId();
    return prefs.getBool('trial_activated_$deviceId') != true;
  }

  static Future<bool> activateTrial() async {
    if (!await canStartTrial()) return false;

    final settingsRepo = getIt<SettingsRepository>();
    final settings = await settingsRepo.getSettings();
    if (settings == null) return false;

    final deviceId = await getDeviceId();
    final expiryDate = DateTime.now().add(trialDuration);
    final payload = "$trialPrefix:$deviceId";

    await settingsRepo.updateSettings(
      settings.copyWith(
        licenseKey: Value(payload),
        expiryDate: Value(expiryDate),
      ),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('trial_activated_$deviceId', true);
    return true;
  }
}
