import 'package:get_it/get_it.dart';
import '../../database/database.dart';

// =========================
// DAO
// =========================
import '../../database/dao/settings_dao.dart';
import '../../database/dao/products_dao.dart';
import '../../database/dao/users_dao.dart';
import '../../database/dao/customers_dao.dart';
import '../../database/dao/suppliers_dao.dart';
import '../../database/dao/purchases_dao.dart';
import '../../database/dao/invoices_dao.dart';
import '../../database/dao/warehouses_dao.dart';
import '../../database/dao/reports_dao.dart';

// =========================
// Repository
// =========================
import '../../repositories/settings_repository.dart';
import '../../repositories/products_repository.dart';
import '../../repositories/users_repository.dart';
import '../../repositories/customers_repository.dart';
import '../../repositories/suppliers_repository.dart';
import '../../repositories/purchases_repository.dart';
import '../../repositories/invoices_repository.dart';
import '../../repositories/warehouses_repository.dart';
import '../../repositories/reports_repository.dart';

// =========================
// Services
// =========================
import 'startup_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // =========================
  // Database
  // =========================
  final database = AppDatabase();
  getIt.registerSingleton<AppDatabase>(database);

  // =========================
  // DAO
  // =========================
  getIt.registerLazySingleton<SettingsDao>(() => SettingsDao(getIt<AppDatabase>()));
  getIt.registerLazySingleton<ProductsDao>(() => ProductsDao(getIt<AppDatabase>()));
  getIt.registerLazySingleton<UsersDao>(() => UsersDao(getIt<AppDatabase>()));
  getIt.registerLazySingleton<CustomersDao>(() => CustomersDao(getIt<AppDatabase>()));
  getIt.registerLazySingleton<SuppliersDao>(() => SuppliersDao(getIt<AppDatabase>()));
  getIt.registerLazySingleton<PurchasesDao>(() => PurchasesDao(getIt<AppDatabase>()));
  getIt.registerLazySingleton<InvoicesDao>(() => InvoicesDao(getIt<AppDatabase>()));
  getIt.registerLazySingleton<WarehousesDao>(() => WarehousesDao(getIt<AppDatabase>()));
  getIt.registerLazySingleton<ReportsDao>(() => ReportsDao(getIt<AppDatabase>()));

  // =========================
  // Repository
  // =========================
  getIt.registerLazySingleton<SettingsRepository>(() => SettingsRepository(getIt<SettingsDao>()));
  getIt.registerLazySingleton<ProductsRepository>(() => ProductsRepository(getIt<ProductsDao>()));
  getIt.registerLazySingleton<UsersRepository>(() => UsersRepository(getIt<UsersDao>()));
  getIt.registerLazySingleton<CustomersRepository>(() => CustomersRepository(getIt<CustomersDao>()));
  getIt.registerLazySingleton<SuppliersRepository>(() => SuppliersRepository(getIt<SuppliersDao>()));
  getIt.registerLazySingleton<PurchasesRepository>(() => PurchasesRepository(getIt<PurchasesDao>()));
  getIt.registerLazySingleton<InvoicesRepository>(() => InvoicesRepository(getIt<InvoicesDao>()));
  getIt.registerLazySingleton<WarehousesRepository>(() => WarehousesRepository(getIt<WarehousesDao>()));
  getIt.registerLazySingleton<ReportsRepository>(() => ReportsRepository(getIt<ReportsDao>()));

  // =========================
  // Services
  // =========================
  getIt.registerLazySingleton<StartupService>(() => StartupService(getIt<SettingsRepository>()));

  // Initialize Admin User
  await getIt<SettingsDao>().initDefaultAdmin();
}
