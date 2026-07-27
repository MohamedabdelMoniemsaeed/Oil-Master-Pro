import 'package:drift/drift.dart';

import '../database.dart';


part 'settings_dao.g.dart';



@DriftAccessor(
  tables: [SettingsTable],
)

class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {


  SettingsDao(super.db);



  Future<SettingsTableData?> getSettings() {

    return select(settingsTable)
        .getSingleOrNull();

  }



  Future<int> saveSettings(
    SettingsTableCompanion settings,
  ) {


    return into(settingsTable)
        .insert(settings);

  }



  Future<bool> updateSettings(
    SettingsTableData settings,
  ) {


    return update(settingsTable)
        .replace(settings);

  }


}