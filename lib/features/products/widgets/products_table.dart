import 'package:fluent_ui/fluent_ui.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../../database/database.dart';
import 'products_data_source.dart';

class ProductsTable extends StatelessWidget {
  final List<ProductsTableData> products;

  const ProductsTable({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final source = ProductsDataSource(products);

    return SfDataGrid(
      source: source,
      columnWidthMode: ColumnWidthMode.fill,
      columns: [
        GridColumn(
          columnName: "name",
          label: const Center(
            child: Text("المنتج"),
          ),
        ),
        GridColumn(
          columnName: "barcode",
          label: const Center(
            child: Text("الباركود"),
          ),
        ),
        GridColumn(
          columnName: "purchase",
          label: const Center(
            child: Text("الشراء"),
          ),
        ),
        GridColumn(
          columnName: "sale",
          label: const Center(
            child: Text("البيع"),
          ),
        ),
        GridColumn(
          columnName: "quantity",
          label: const Center(
            child: Text("المخزون"),
          ),
        ),
      ],
    );
  }
}