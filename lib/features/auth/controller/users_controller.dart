import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/service_locator.dart';
import '../../../database/database.dart';
import '../../../repositories/users_repository.dart';
import '../../../core/services/permission_service.dart';
import 'auth_controller.dart';

class UsersController extends StateNotifier<List<UsersTableData>> {
  final Ref _ref;
  UsersController(this._ref) : super([]) {
    loadUsers();
  }

  final UsersRepository _repository = getIt<UsersRepository>();

  Future<void> loadUsers() async {
    final currentUser = _ref.read(authControllerProvider).user;
    if (!PermissionService.canManageUsers(currentUser)) {
      state = [];
      return;
    }
    state = await _repository.getUsers();
  }

  Future<void> addUser(UsersTableCompanion user) async {
    final currentUser = _ref.read(authControllerProvider).user;
    if (!PermissionService.canManageUsers(currentUser)) return;

    // منع المشرف من إنشاء مستخدم Admin
    if (currentUser?.role == 'supervisor' && user.role.value == 'admin') {
      throw Exception("لا يمكن للمشرف إنشاء مستخدم بصلاحية مدير نظام.");
    }

    await _repository.createUser(user);
    await loadUsers();
  }

  Future<void> deleteUser(int id) async {
    final currentUser = _ref.read(authControllerProvider).user;
    if (!PermissionService.canManageUsers(currentUser)) return;

    // جلب بيانات المستخدم المراد حذفه للتأكد من رتبته
    final users = await _repository.getUsers();
    final targetUser = users.firstWhere((u) => u.id == id);

    // منع المشرف من حذف مستخدم Admin
    if (currentUser?.role == 'supervisor' && targetUser.role == 'admin') {
      throw Exception("لا يمكن للمشرف حذف مستخدم بصلاحية مدير نظام.");
    }

    await _repository.deleteUser(id);
    await loadUsers();
  }
}

final usersControllerProvider =
    StateNotifierProvider<UsersController, List<UsersTableData>>((ref) {
  return UsersController(ref);
});
