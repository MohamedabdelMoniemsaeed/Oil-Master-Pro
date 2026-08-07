import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/settings_table.dart';

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

  Future<void> initDefaultAdmin() async {
    final users = await db.select(db.usersTable).get();
    if (users.isEmpty) {
      await db.into(db.usersTable).insert(
        UsersTableCompanion.insert(
          username: "admin",
          password: "123",
          fullName: "مدير النظام",
          role: const Value("admin"),
        ),
      );
    }
  }


}