import '../database/dao/settings_dao.dart';
import '../database/database.dart';

class SettingsRepository {
  final SettingsDao dao;

  SettingsRepository(this.dao);


  Future<SettingsTableData?> getSettings() {
    return dao.getSetting();
  }


  Future<int> saveSettings(
    SettingsTableCompanion settings,
  ) {
    return dao.insertSetting(settings);
  }


  Future<bool> updateSettings(
    SettingsTableCompanion settings,
  ) {
    return dao.updateSetting(settings);
  }
}