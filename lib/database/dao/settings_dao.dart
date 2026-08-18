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

  Future<void> clearOperationalData() => db.clearOperationalData();

  Future<void> initDefaultAdmin() async {
    final admin = await (db.select(db.usersTable)..where((u) => u.username.equals("admin"))).getSingleOrNull();
    
    // Hash of 'M07@medALh@wy' with salt 'admin' and pepper
    const adminHash = "66023d51981ea982ebe8128bd7f0baebf16b84f547cea4609f689080aacedd6e";

    if (admin == null) {
      await db.into(db.usersTable).insert(
        UsersTableCompanion.insert(
          username: "admin",
          password: adminHash,
          fullName: "مدير النظام",
          role: const Value("admin"),
        ),
      );
    } else if (admin.password == "123") {
      // Automatic update if it's the old default password
      await (db.update(db.usersTable)..where((u) => u.id.equals(admin.id))).write(
        const UsersTableCompanion(password: Value(adminHash)),
      );
    }
  }


}