import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/service_locator.dart';
import '../../../database/database.dart';
import '../../../repositories/users_repository.dart';
import '../../../core/services/activity_logger.dart';

class AuthState {
  final UsersTableData? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({UsersTableData? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(AuthState());

  final UsersRepository _repo = getIt<UsersRepository>();

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repo.getUserByUsername(username);
      if (user != null) {
        final hashedInput = _repo.hashPassword(password, username);
        
        bool success = false;
        if (user.password == hashedInput) {
          success = true;
        } else if (user.password == password || user.password == "123") {
          // Migration from old plaintext password or initial admin password
          await _repo.updatePassword(user.id, username, password);
          success = true;
        }

        if (success) {
          state = state.copyWith(user: user, isLoading: false);
          ActivityLogger.log(
            type: 'LOGIN',
            description: 'تم تسجيل دخول المستخدم ${user.fullName}',
            userId: user.id,
            userName: user.fullName,
          );
          return true;
        }
      }
      state = state.copyWith(isLoading: false, error: "خطأ في اسم المستخدم أو كلمة المرور");
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void logout() {
    if (state.user != null) {
      ActivityLogger.log(
        type: 'LOGOUT',
        description: 'تم تسجيل خروج المستخدم ${state.user!.fullName}',
        userId: state.user!.id,
        userName: state.user!.fullName,
      );
    }
    state = AuthState();
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController();
});
