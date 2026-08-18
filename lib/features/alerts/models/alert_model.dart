enum AlertType { lowStock, outOfStock }

class AppAlert {
  final AlertType type;
  final String title;
  final String subtitle;
  final String? id;
  final String? warehouseName;
  final int? currentQty;
  final int? minQty;
  final int? warehouseId;

  AppAlert({
    required this.type,
    required this.title,
    required this.subtitle,
    this.id,
    this.warehouseName,
    this.currentQty,
    this.minQty,
    this.warehouseId,
  });
}
