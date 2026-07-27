import '../database/database.dart';
import '../database/dao/customers_dao.dart';


class CustomersRepository {


  final CustomersDao dao;


  CustomersRepository(
    this.dao,
  );



  Future<List<CustomersTableData>> getCustomers(){

    return dao.getAllCustomers();

  }



  Future<int> addCustomer(
    CustomersTableCompanion customer,
  ){

    return dao.addCustomer(
      customer,
    );

  }



  Future<bool> updateCustomer(
    CustomersTableData customer,
  ){

    return dao.updateCustomer(
      customer,
    );

  }



  Future<int> deleteCustomer(
    int id,
  ){

    return dao.deleteCustomer(
      id,
    );

  }



  Future<List<CustomersTableData>> searchCustomers(
    String value,
  ){

    return dao.search(
      value,
    );

  }

}