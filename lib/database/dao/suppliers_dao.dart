import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/suppliers_table.dart';

part 'suppliers_dao.g.dart';

@DriftAccessor(
  tables: [SuppliersTable],
)

class SuppliersDao extends DatabaseAccessor<AppDatabase>
    with _$SuppliersDaoMixin {


  SuppliersDao(super.db);



  Future<List<SuppliersTableData>> getAllSuppliers(){

    return select(suppliersTable).get();

  }




  Future<int> addSupplier(
    SuppliersTableCompanion supplier,
  ){

    return into(suppliersTable)
        .insert(supplier);

  }





  Future<bool> updateSupplier(
    SuppliersTableData supplier,
  ){

    return update(suppliersTable)
        .replace(supplier);

  }





  Future<int> deleteSupplier(
    int id,
  ){

    return (delete(suppliersTable)
      ..where(
        (tbl)=>tbl.id.equals(id),
      ))
      .go();

  }





  Future<List<SuppliersTableData>> search(
    String value,
  ){

    return (select(suppliersTable)

      ..where(
        (tbl)=>
            tbl.name.contains(value) |
            tbl.phone.contains(value),
      )

    ).get();

  }


}