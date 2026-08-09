class UserRole {
  static const String admin = 'admin';
  static const String manager = 'manager';
  static const String cashier = 'cashier';
  static const String viewer = 'viewer';

  static const List<String> allRoles = [admin, manager, cashier, viewer];

  static Map<String, String> roleNames = {
    admin: 'مسؤول',
    manager: 'مدير',
    cashier: 'أمين صندوق',
    viewer: 'مشاهد',
  };

  static Map<String, List<String>> rolePermissions = {
    admin: [
      'view_dashboard',
      'manage_products',
      'manage_customers',
      'create_invoice',
      'delete_invoice',
      'manage_purchases',
      'view_reports',
      'manage_users',
      'manage_license',
      'view_settings',
      'manage_settings',
    ],
    manager: [
      'view_dashboard',
      'manage_products',
      'manage_customers',
      'create_invoice',
      'manage_purchases',
      'view_reports',
      'view_settings',
    ],
    cashier: [
      'view_dashboard',
      'view_products',
      'view_customers',
      'create_invoice',
      'view_reports',
    ],
    viewer: [
      'view_dashboard',
      'view_products',
      'view_customers',
      'view_reports',
    ],
  };

  static bool hasPermission(String userRole, String permission) {
    return rolePermissions[userRole]?.contains(permission) ?? false;
  }

  static String getRoleName(String role) {
    return roleNames[role] ?? role;
  }
}
