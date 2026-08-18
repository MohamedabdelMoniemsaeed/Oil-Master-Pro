import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/service_locator.dart';
import '../../../database/database.dart';
import '../../../repositories/customers_repository.dart';



class CustomersController
    extends StateNotifier<List<CustomersTableData>> {


  CustomersController()
      : super([]){

    loadCustomers();

  }



  final CustomersRepository repository =
      getIt<CustomersRepository>();



  Future<void> loadCustomers() async {


    state =
        await repository.getCustomers();


  }



  Future<void> addCustomer(
    CustomersTableCompanion customer,
  ) async {


    await repository.addCustomer(
      customer,
    );


    await loadCustomers();

  }

  Future<void> updateCustomer(
    CustomersTableData customer,
  ) async {
    await repository.dao.updateCustomer(customer);
    await loadCustomers();
  }



  Future<String?> deleteCustomer(
    int id,
  ) async {
    try {
      await repository.deleteCustomer(
        id,
      );
      await loadCustomers();
      return null;
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }



  Future<void> search(
    String value,
  ) async {


    if(value.isEmpty){

      loadCustomers();

      return;

    }


    state =
        await repository.searchCustomers(
          value,
        );

  }


}



final customersControllerProvider =
StateNotifierProvider<
    CustomersController,
    List<CustomersTableData>
>(

  (ref) =>
      CustomersController(),

);