import 'package:flutter_test/flutter_test.dart';
import 'package:oilHub/core/services/license_service.dart';

void main() {
  group('LicenseService', () {
    test('accepts a valid yearly license for the same device', () {
      final now = DateTime(2026, 8, 9);
      final deviceId = 'device-123';
      final payload = LicenseService.buildLicensePayload(
        LicenseService.demoLicenseKey,
        deviceId,
        now.add(const Duration(days: 365)),
      );

      final result = LicenseService.validateStoredLicense(
        payload,
        currentDeviceId: deviceId,
        now: now,
        expectedKey: LicenseService.demoLicenseKey,
      );

      expect(result.isValid, isTrue);
    });

    test('rejects an expired license', () {
      final now = DateTime(2026, 8, 9);
      final deviceId = 'device-123';
      final payload = LicenseService.buildLicensePayload(
        LicenseService.demoLicenseKey,
        deviceId,
        now.subtract(const Duration(days: 1)),
      );

      final result = LicenseService.validateStoredLicense(
        payload,
        currentDeviceId: deviceId,
        now: now,
        expectedKey: LicenseService.demoLicenseKey,
      );

      expect(result.isValid, isFalse);
    });

    test('rejects a license from a different device', () {
      final now = DateTime(2026, 8, 9);
      final payload = LicenseService.buildLicensePayload(
        LicenseService.demoLicenseKey,
        'device-456',
        now.add(const Duration(days: 365)),
      );

      final result = LicenseService.validateStoredLicense(
        payload,
        currentDeviceId: 'device-123',
        now: now,
        expectedKey: LicenseService.demoLicenseKey,
      );

      expect(result.isValid, isFalse);
    });
  });
}
