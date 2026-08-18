import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

import '../../../database/database.dart';
import '../../../core/services/service_locator.dart';
import '../../../repositories/settings_repository.dart';


import '../../auth/controller/auth_controller.dart';

final settingsRepositoryProvider =
    Provider<SettingsRepository>((ref) {
  return getIt<SettingsRepository>();
});


final settingsControllerProvider =
    StateNotifierProvider<SettingsController,
        AsyncValue<SettingsTableData?>>((ref) {

  return SettingsController(
    ref.read(settingsRepositoryProvider),
    ref,
  );

});


class SettingsController
    extends StateNotifier<AsyncValue<SettingsTableData?>> {


  final SettingsRepository repository;
  final Ref ref;


  SettingsController(this.repository, this.ref)
      : super(const AsyncLoading()) {

    loadSettings();

  }


  Future<void> loadSettings() async {

    try {

      final data =
          await repository.getSettings();

      state = AsyncData(data);

    } catch (e) {

      state =
          AsyncError(e, StackTrace.current);

    }

  }


  Future<void> saveShopSettings({
    required String shopName,
    String? phone,
    String? address,
    required String language,
    required String currency,
  }) async {

    final currentUser = ref.read(authControllerProvider).user;

    final setting =
        SettingsTableCompanion(

      shopName:
          Value(shopName),

      phone:
          Value(phone),

      address:
          Value(address),

      language:
          Value(language),

      currency:
          Value(currency),

      isFirstRun:
          const Value(false),

    );


    await repository.saveSettings(setting, user: currentUser);


    await loadSettings();

  }

}
