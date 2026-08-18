import 'user_role_service.dart';
import '../../database/database.dart';

class PermissionService {
  static bool canManageUsers(UsersTableData? user) => user?.role == 'admin' || user?.role == 'supervisor';
  static bool canAccessSettings(UsersTableData? user) => user?.role == 'admin' || user?.role == 'supervisor';
  static bool canManageWarehouses(UsersTableData? user) => user?.role == 'admin' || user?.role == 'supervisor';
  static bool canViewReports(UsersTableData? user) => user?.role == 'admin' || user?.role == 'supervisor';
  static bool canManagePurchases(UsersTableData? user) => user?.role == 'admin' || user?.role == 'supervisor';
  
  static bool canBackup(UsersTableData? user) => user?.role == 'admin' || user?.role == 'supervisor';
  static bool canRestore(UsersTableData? user) => user?.role == 'admin';

  static bool canManageLicense(UsersTableData? user) => user?.role == 'admin' || user?.role == 'supervisor';

  static bool canPerformSensitiveAction(UsersTableData? user) {
    // For actions like deleting products or adjusting stock manually
    return user?.role == 'admin' || user?.role == 'supervisor';
  }
}
