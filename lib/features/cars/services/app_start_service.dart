import '../../../database/database.dart';
import '../../../repositories/settings_repository.dart';

class StartupService {
  final SettingsRepository repository;

  StartupService(this.repository);

  Future<bool> isFirstRun() async {
    final settings = await repository.getSettings();
    if (settings == null) {
      return true;
    }
    return false;
  }
}
