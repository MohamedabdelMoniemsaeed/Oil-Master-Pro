import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/users_table.dart';

part 'users_dao.g.dart';

@DriftAccessor(tables: [UsersTable])
class UsersDao extends DatabaseAccessor<AppDatabase>
    with _$UsersDaoMixin {

  UsersDao(super.db);


  // جلب مستخدم بواسطة الاسم
  Future<UsersTableData?> getUserByUsername(
    String username,
  ) {

    return (select(usersTable)
      ..where(
        (tbl) =>
            tbl.username.equals(username),
      ))
      .getSingleOrNull();

  }



  // إضافة مستخدم جديد
  Future<int> addUser(
    UsersTableCompanion user,
  ) {

    return into(usersTable)
        .insert(user);

  }



  // تحديث مستخدم
  Future<bool> updateUser(
    UsersTableCompanion user,
  ) async {

    final count = await update(usersTable)
        .write(user);
    return count > 0;

  }



  // حذف مستخدم
  Future<int> deleteUser(
    int id,
  ) {

    return (delete(usersTable)
      ..where(
        (tbl) =>
            tbl.id.equals(id),
      ))
      .go();

  }



  // جلب كل المستخدمين
  Future<List<UsersTableData>> getUsers() {

    return select(usersTable)
        .get();

  }

}