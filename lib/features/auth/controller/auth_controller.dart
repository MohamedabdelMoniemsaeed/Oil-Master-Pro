import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/service_locator.dart';
import '../../../repositories/users_repository.dart';


final usersRepositoryProvider =
    Provider<UsersRepository>((ref) {

  return getIt<UsersRepository>();

});



final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<bool>>(
        (ref) {

  return AuthController(
    ref.read(usersRepositoryProvider),
  );

});



class AuthController
    extends StateNotifier<AsyncValue<bool>> {


  final UsersRepository repository;


  AuthController(
    this.repository,
  ) : super(
    const AsyncData(false),
  );



  Future<bool> login(
    String username,
    String password,
  ) async {


    state =
        const AsyncLoading();



    final user =
        await repository.login(username);



    if (user == null) {

      state =
          const AsyncData(false);

      return false;

    }



    if (user.password == password) {

      state =
          const AsyncData(true);

      return true;

    }



    state =
        const AsyncData(false);

    return false;

  }

}