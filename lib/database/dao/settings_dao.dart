import 'package:drift/drift.dart';

import '../database.dart';

@DriftAccessor(tables: [SettingsTable])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {

  SettingsDao(super.db);

  Future<List<SettingsTableData>> getSettings() {
    return select(settingsTable).get();
  }


  Future<SettingsTableData?> getSetting() async {
    final query = select(settingsTable);

    return query.getSingleOrNull();
  }


  Future<int> insertSetting(
      SettingsTableCompanion setting,
      ) {
    return into(settingsTable).insert(setting);
  }


  Future<bool> updateSetting(
      SettingsTableCompanion setting,
      ) {
    return update(settingsTable).write(setting);
  }


  Future<int> deleteSetting(
      int id,
      ) {
    return (delete(settingsTable)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
  }
}