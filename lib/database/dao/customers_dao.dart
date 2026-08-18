import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/customers_table.dart';
import '../tables/invoices_table.dart';

part 'customers_dao.g.dart';

@DriftAccessor(tables: [CustomersTable, InvoicesTable])
class CustomersDao extends DatabaseAccessor<AppDatabase> with _$CustomersDaoMixin {
  CustomersDao(super.db);

  Future<List<CustomersTableData>> getAllCustomers() {
    return select(customersTable).get();
  }

  Future<int> addCustomer(CustomersTableCompanion customer) {
    return into(customersTable).insert(customer);
  }

  Future<bool> updateCustomer(CustomersTableData customer) {
    return update(customersTable).replace(customer);
  }

  Future<void> deleteCustomerSecurely(int id) async {
    return transaction(() async {
      // التحقق من وجود فواتير مرتبطة
      final invoice = await (select(db.invoicesTable)..where((t) => t.customerId.equals(id))..limit(1)).getSingleOrNull();
      if (invoice != null) {
        throw Exception("لا يمكن حذف العميل لوجود فواتير مبيعات مرتبطة به. يمكنك تعديل بياناته بدلاً من حذفه.");
      }
      
      await (delete(customersTable)..where((tbl) => tbl.id.equals(id))).go();
    });
  }

  Future<List<CustomersTableData>> search(String value) {
    return (select(customersTable)
          ..where((tbl) => tbl.name.contains(value) | tbl.phone.contains(value)))
        .get();
  }

  Future<int> getCustomersCount() async {
    final countExp = customersTable.id.count();
    final query = selectOnly(customersTable)..addColumns([countExp]);
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }
}
