import '../../database/database.dart';
import '../../repositories/settings_repository.dart';


class AppStartService {

  final SettingsRepository repository;


  AppStartService(
    this.repository,
  );


  Future<bool> isFirstRun() async {

    final settings =
        await repository.getSettings();


    if (settings == null) {
      return true;
    }


    return settings.isFirstRun;

  }

}