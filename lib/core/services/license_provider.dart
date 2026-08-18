import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'license_service.dart';

final licenseInfoProvider = FutureProvider<AppLicenseInfo>((ref) async {
  return await LicenseService.getLicenseInfo();
});

final isActivatedProvider = Provider<bool>((ref) {
  final licenseAsync = ref.watch(licenseInfoProvider);
  return licenseAsync.maybeWhen(
    data: (info) => info.isVerified && info.status == "Active",
    orElse: () => false,
  );
});
