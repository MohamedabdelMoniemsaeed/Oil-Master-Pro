import '../database/database.dart';
import '../database/dao/settings_dao.dart';



class SettingsRepository {


  final SettingsDao dao;



  SettingsRepository(
    this.dao,
  );




  Future<SettingsTableData?> getSettings(){

    return dao.getSettings();

  }




  Future<int> saveSettings(
    SettingsTableCompanion settings, {
    UsersTableData? user,
  }) {
    if (user != null && user.role != 'admin' && user.role != 'supervisor') {
      throw Exception("ليس لديك صلاحية لتغيير إعدادات النظام.");
    }
    return dao.saveSettings(
      settings,
    );
  }

  Future<bool> updateSettings(
    SettingsTableData settings, {
    UsersTableData? user,
  }) {
    if (user != null && user.role != 'admin' && user.role != 'supervisor') {
      throw Exception("ليس لديك صلاحية لتغيير إعدادات النظام.");
    }
    return dao.updateSettings(
      settings,
    );
  }

  Future<void> clearOperationalData() => dao.clearOperationalData();


}