import '../database/dao/users_dao.dart';
import '../database/database.dart';


class UsersRepository {

  final UsersDao dao;


  UsersRepository(
    this.dao,
  );


  Future<UsersTableData?> login(
    String username,
  ) {

    return dao.getUserByUsername(
      username,
    );

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
    return dao.addUser(
      user,
    );
  }

  Future<List<UsersTableData>> getUsers() {
    return dao.getUsers();
  }

  Future<int> deleteUser(int id) {
    return dao.deleteUser(id);
  }
}