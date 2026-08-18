import 'package:drift/drift.dart';
import 'users_table.dart';
import 'customers_table.dart';

class InvoicesTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get invoiceNumber => text()();

  IntColumn get customerId => integer().nullable().references(CustomersTable, #id, onDelete: KeyAction.restrict)();

  // سيتم الحفاظ على الحقول تقنياً لثبات قاعدة البيانات ولكن بدون علاقة خارجية بجدول السيارات المحذوف
  IntColumn get carId => integer().nullable()();
  
  IntColumn get userId => integer().nullable().references(UsersTable, #id, onDelete: KeyAction.restrict)();

  IntColumn get currentKm => integer().nullable()();
  
  RealColumn get total => real()();

  RealColumn get discount =>
      real().withDefault(const Constant(0))();

  RealColumn get tax =>
      real().withDefault(const Constant(0))();

  RealColumn get paid =>
      real().withDefault(const Constant(0))();

  RealColumn get remaining =>
      real().withDefault(const Constant(0))();

  TextColumn get paymentMethod =>
      text().withDefault(const Constant("Cash"))();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}
