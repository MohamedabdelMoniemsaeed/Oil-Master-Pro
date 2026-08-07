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



  Future<void> deleteCustomer(
    int id,
  ) async {


    await repository.deleteCustomer(
      id,
    );


    await loadCustomers();

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