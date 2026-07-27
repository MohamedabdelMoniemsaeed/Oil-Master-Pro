import 'package:fluent_ui/fluent_ui.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../../database/database.dart';

class ProductsDataSource extends DataGridSource {
  ProductsDataSource(List<ProductsTableData> products) {
    _rows = products.map((product) {
      return DataGridRow(
        cells: [
          DataGridCell<int>(
            columnName: "id",
            value: product.id,
          ),
          DataGridCell<String>(
            columnName: "name",
            value: product.nameAr,
          ),
          DataGridCell<String>(
            columnName: "barcode",
            value: product.barcode ?? "",
          ),
          DataGridCell<double>(
            columnName: "purchase",
            value: product.purchasePrice,
          ),
          DataGridCell<double>(
            columnName: "sale",
            value: product.salePrice,
          ),
          DataGridCell<int>(
            columnName: "quantity",
            value: product.quantity,
          ),
        ],
      );
    }).toList();
  }

  late final List<DataGridRow> _rows;

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map((cell) {
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8),
          child: Text(
            cell.value.toString(),
          ),
        );
      }).toList(),
    );
  }
}