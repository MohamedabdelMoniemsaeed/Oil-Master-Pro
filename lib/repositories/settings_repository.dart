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
    SettingsTableCompanion settings,
  ){

    return dao.saveSettings(
      settings,
    );

  }




  Future<bool> updateSettings(
    SettingsTableData settings,
  ){

    return dao.updateSettings(
      settings,
    );

  }


}