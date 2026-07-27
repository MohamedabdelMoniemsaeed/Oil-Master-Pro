import 'package:get_it/get_it.dart';

import '../../database/database.dart';

import '../../database/dao/settings_dao.dart';
import '../../database/dao/products_dao.dart';

import '../../repositories/settings_repository.dart';
import '../../repositories/products_repository.dart';

import 'app_start_service.dart';


final getIt = GetIt.instance;


Future<void> setupServiceLocator() async {


  // Database

  final database = AppDatabase();


  getIt.registerSingleton<AppDatabase>(
    database,
  );



  // DAO

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



  // Repository

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



  // Services

  getIt.registerLazySingleton<AppStartService>(
    () => AppStartService(
      getIt<SettingsRepository>(),
    ),
  );

}