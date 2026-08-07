import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/service_locator.dart';
import '../../../database/database.dart';
import '../../../repositories/users_repository.dart';

class UsersController extends StateNotifier<List<UsersTableData>> {
  UsersController() : super([]);

  final UsersRepository _repo = getIt<UsersRepository>();

  Future<void> loadUsers() async {
    state = await _repo.getUsers();
  }

  Future<void> addUser(UsersTableCompanion user) async {
    await _repo.createUser(user);
    await loadUsers();
  }

  Future<void> deleteUser(int id) async {
    await _repo.deleteUser(id);
    await loadUsers();
  }
}

final usersControllerProvider =
    StateNotifierProvider<UsersController, List<UsersTableData>>((ref) {
  return UsersController();
});
