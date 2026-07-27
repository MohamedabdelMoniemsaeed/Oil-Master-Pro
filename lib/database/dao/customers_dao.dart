import 'package:drift/drift.dart';

import '../database.dart';


part 'customers_dao.g.dart';


@DriftAccessor(
  tables: [CustomersTable],
)

class CustomersDao extends DatabaseAccessor<AppDatabase>
    with _$CustomersDaoMixin {


  CustomersDao(super.db);



  Future<List<CustomersTableData>> getAllCustomers(){

    return select(customersTable).get();

  }



  Future<int> addCustomer(
    CustomersTableCompanion customer,
  ){

    return into(customersTable)
        .insert(customer);

  }



  Future<bool> updateCustomer(
    CustomersTableData customer,
  ){

    return update(customersTable)
        .replace(customer);

  }



  Future<int> deleteCustomer(
    int id,
  ){

    return (delete(customersTable)
      ..where(
        (tbl)=>tbl.id.equals(id),
      ))
      .go();

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

  }

}