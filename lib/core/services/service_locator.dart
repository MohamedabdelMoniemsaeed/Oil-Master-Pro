import 'package:get_it/get_it.dart';

import '../../database/database.dart';
import '../../database/dao/invoices_dao.dart';
import '../../repositories/invoices_repository.dart';
// DAO
import '../../database/dao/settings_dao.dart';
import '../../database/dao/products_dao.dart';
import '../../database/dao/users_dao.dart';

// Repository
import '../../repositories/settings_repository.dart';
import '../../repositories/products_repository.dart';
import '../../repositories/users_repository.dart';

// Services
import 'app_start_service.dart';


final getIt = GetIt.instance;



Future<void> setupServiceLocator() async {


  // =========================
  // Database
  // =========================

  final database = AppDatabase();


  getIt.registerSingleton<AppDatabase>(
    database,
  );



  // =========================
  // DAO
  // =========================
getIt.registerLazySingleton<InvoicesDao>(
  () => InvoicesDao(
    getIt<AppDatabase>(),
  ),
);

  getIt.registerLazySingleton<SettingsDao>(
    () => SettingsDao(
      getIt<AppDatabase>(),
    ),
  );


  getIt.registerLazySingleton<ProductsDao>(
    () => ProductsDao(
      getIt<AppDatabase>(),
    ),
  );


  getIt.registerLazySingleton<UsersDao>(
    () => UsersDao(
      getIt<AppDatabase>(),
    ),
  );



  // =========================
  // Repository
  // =========================

getIt.registerLazySingleton<InvoicesRepository>(
  () => InvoicesRepository(
    getIt<InvoicesDao>(),
  ),
);

  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepository(
      getIt<SettingsDao>(),
    ),
  );


  getIt.registerLazySingleton<ProductsRepository>(
    () => ProductsRepository(
      getIt<ProductsDao>(),
    ),
  );


  getIt.registerLazySingleton<UsersRepository>(
    () => UsersRepository(
      getIt<UsersDao>(),
    ),
  );



  // =========================
  // Services
  // =========================


  getIt.registerLazySingleton<AppStartService>(
    () => AppStartService(
      getIt<SettingsRepository>(),
    ),
  );

}