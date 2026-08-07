import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/customers_table.dart';

part 'customers_dao.g.dart';

@DriftAccessor(
  tables: [CustomersTable],
)

class CustomersDao extends DatabaseAccessor<AppDatabase>
    with _$CustomersDaoMixin {


  CustomersDao(super.db);



  Future<List<CustomersTableData>> getAllCustomers(){

    return select(customersTable).get();

    Future<int> getCustomersCount() async {
    final countExp = customersTable.id.count();
    final query = selectOnly(customersTable)..addColumns([countExp]);
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }
}



  Future<int> addCustomer(
    CustomersTableCompanion customer,
  ){

    return into(customersTable)
        .insert(customer);

    Future<int> getCustomersCount() async {
    final countExp = customersTable.id.count();
    final query = selectOnly(customersTable)..addColumns([countExp]);
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }
}



  Future<bool> updateCustomer(
    CustomersTableData customer,
  ){

    return update(customersTable)
        .replace(customer);

    Future<int> getCustomersCount() async {
    final countExp = customersTable.id.count();
    final query = selectOnly(customersTable)..addColumns([countExp]);
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }
}



  Future<int> deleteCustomer(
    int id,
  ){

    return (delete(customersTable)
      ..where(
        (tbl)=>tbl.id.equals(id),
      ))
      .go();

    Future<int> getCustomersCount() async {
    final countExp = customersTable.id.count();
    final query = selectOnly(customersTable)..addColumns([countExp]);
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }
}



  Future<List<CustomersTableData>> search(
    String value,
  ){

    return (select(customersTable)
      ..where(
        (tbl)=>
        tbl.name.contains(value) |
        tbl.phone.contains(value),
      ))
      .get();

    Future<int> getCustomersCount() async {
    final countExp = customersTable.id.count();
    final query = selectOnly(customersTable)..addColumns([countExp]);
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }
}

  Future<int> getCustomersCount() async {
    final countExp = customersTable.id.count();
    final query = selectOnly(customersTable)..addColumns([countExp]);
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }
}