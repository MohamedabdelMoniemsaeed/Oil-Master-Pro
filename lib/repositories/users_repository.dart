import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import '../database/dao/users_dao.dart';
import '../database/database.dart';


class UsersRepository {

  final UsersDao dao;


  UsersRepository(
    this.dao,
  );

  static const String _pepper = "OIL_MASTER_PRO_SECURE_PEPPER_2026";

  String hashPassword(String password, String username) {
    // Adding username as a salt + global pepper
    final bytes = utf8.encode("$username:$_pepper:$password");
    return sha256.convert(bytes).toString();
  }

  Future<UsersTableData?> getUserByUsername(
    String username,
  ) {
    return dao.getUserByUsername(
      username,
    );
  }

  Future<int> createUser(
    UsersTableCompanion user,
  ) {
    if (user.password.present && user.username.present) {
      final hashed = hashPassword(user.password.value, user.username.value);
      return dao.addUser(
        user.copyWith(password: Value(hashed)),
      );
    }
    return dao.addUser(
      user,
    );
  }

  Future<bool> updatePassword(int userId, String username, String newPassword) {
    final hashed = hashPassword(newPassword, username);
    return dao.updateUser(
      UsersTableCompanion(
        id: Value(userId),
        password: Value(hashed),
      ),
    );
  }

  Future<List<UsersTableData>> getUsers() {
    return dao.getUsers();
  }

  Future<int> deleteUser(int id) {
    return dao.deleteUser(id);
  }
}
