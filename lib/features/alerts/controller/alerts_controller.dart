import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:rxdart/rxdart.dart';
import '../../../core/services/service_locator.dart';
import '../../../database/database.dart';
import '../../../repositories/warehouses_repository.dart';
import '../models/alert_model.dart';

class AlertsController extends StateNotifier<List<AppAlert>> {
  AlertsController() : super([]) {
    _init();
  }

  final WarehousesRepository _warehousesRepo = getIt<WarehousesRepository>();
  StreamSubscription? _subscription;

  int? _filterWarehouseId;
  AlertType? _filterType;

  void _init() {
    _subscription?.cancel();

    final stockStream = _warehousesRepo.watchStockAlerts();

    _subscription = stockStream.listen((stockData) {
      final List<AppAlert> allAlerts = [];

      // 2. Process Stock Alerts
      for (final row in stockData) {
        final pw = row.readTable(getIt<AppDatabase>().productWarehousesTable);
        final p = row.readTable(getIt<AppDatabase>().productsTable);
        final w = row.readTable(getIt<AppDatabase>().warehousesTable);

        if (pw.quantity == 0) {
          allAlerts.add(AppAlert(
            type: AlertType.outOfStock,
            title: "نفاد المخزون: ${p.nameAr}",
            subtitle: "المخزن: ${w.name} | الكمية: 0 | الحد الأدنى: ${p.minimumQuantity}",
            id: "oos-${w.id}-${p.id}",
            warehouseName: w.name,
            currentQty: 0,
            minQty: p.minimumQuantity,
            warehouseId: w.id,
          ));
        } else {
          allAlerts.add(AppAlert(
            type: AlertType.lowStock,
            title: "مخزون منخفض: ${p.nameAr}",
            subtitle: "المخزن: ${w.name} | الكمية: ${pw.quantity} | الحد الأدنى: ${p.minimumQuantity}",
            id: "low-${w.id}-${p.id}",
            warehouseName: w.name,
            currentQty: pw.quantity,
            minQty: p.minimumQuantity,
            warehouseId: w.id,
          ));
        }
      }

      state = _applyFilters(allAlerts);
    });
  }

  List<AppAlert> _applyFilters(List<AppAlert> alerts) {
    var filtered = alerts;
    if (_filterWarehouseId != null) {
      filtered = filtered.where((a) => a.warehouseId == null || a.warehouseId == _filterWarehouseId).toList();
    }
    if (_filterType != null) {
      filtered = filtered.where((a) => a.type == _filterType).toList();
    }

    // Sorting: Out of stock first, then low stock
    filtered.sort((a, b) {
      if (a.type == b.type) return 0;
      if (a.type == AlertType.outOfStock) return -1;
      if (b.type == AlertType.outOfStock) return 1;
      if (a.type == AlertType.lowStock) return -1;
      if (b.type == AlertType.lowStock) return 1;
      return 0;
    });

    return filtered;
  }

  void updateFilters({int? warehouseId, AlertType? type}) {
    _filterWarehouseId = warehouseId;
    _filterType = type;
    _init(); 
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final alertsControllerProvider =
    StateNotifierProvider<AlertsController, List<AppAlert>>((ref) {
  return AlertsController();
});
