import '../database/database.dart';
import '../database/dao/suppliers_dao.dart';



class SuppliersRepository {


  final SuppliersDao dao;



  SuppliersRepository(
    this.dao,
  );




  Future<List<SuppliersTableData>> getSuppliers(){

    return dao.getAllSuppliers();

  }




  Future<int> addSupplier(
    SuppliersTableCompanion supplier,
  ){

    return dao.addSupplier(
      supplier,
    );

  }




  Future<bool> updateSupplier(
    SuppliersTableData supplier,
  ){

    return dao.updateSupplier(
      supplier,
    );

  }




  Future<int> deleteSupplier(
    int id,
  ){

    return dao.deleteSupplier(
      id,
    );

  }




  Future<List<SuppliersTableData>> searchSuppliers(
    String value,
  ){

    return dao.search(
      value,
    );

  }


}