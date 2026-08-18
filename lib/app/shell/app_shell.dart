import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../features/auth/controller/auth_controller.dart';

class AppShell extends ConsumerStatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final routes = [
      '/dashboard', '/products', '/categories', '/warehouses', '/inventory',
      '/sales', '/purchases', '/customers', '/suppliers', '/reports',
      '/alerts', '/users', '/settings', '/license-management'
    ];
    for (int i = 0; i < routes.length; i++) {
      if (location.startsWith(routes[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final selectedIndex = _calculateSelectedIndex(context);

    if (user == null) return Center(child: ProgressRing());

    return material.Directionality(
      textDirection: material.TextDirection.ltr,
      child: NavigationView(
        pane: NavigationPane(
          selected: selectedIndex,
          onChanged: (index) => _onItemTapped(index, context),
          displayMode: PaneDisplayMode.compact,
          header: _buildSidebarHeader(),
          items: _getPaneItems(widget.child),
          footerItems: [
            PaneItemAction(
              icon: Icon(FluentIcons.power_button, color: Colors.red),
              title: Text("تسجيل الخروج", style: TextStyle(color: Colors.red)),
              onTap: () => _handleLogout(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Image.asset('assets/images/Logo2.png', height: 40),
          SizedBox(height: 8),
          Text("POS PRO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
          Text("كاشير احترافي", style: TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildTopAppBar(user) {
    final now = DateTime.now();
    return Container(
      height: 65,
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          _buildUserProfile(user),
          SizedBox(width: 25),
          material.Badge(
            label: Text("5"),
            child: Icon(FluentIcons.action_center, size: 20, color: Colors.grey),
          ),
          Spacer(),
          _buildDateTime(now),
          SizedBox(width: 20),
          _buildSearchBox(),
          SizedBox(width: 20),
          Icon(FluentIcons.global_nav_button, size: 18, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return SizedBox(
      width: 300,
      child: TextBox(
        placeholder: 'ابحث هنا...',
        prefix: Padding(padding: EdgeInsets.all(8), child: Icon(FluentIcons.search)),
      ),
    );
  }

  Widget _buildDateTime(DateTime now) {
    return Row(
      children: [
        Text(DateFormat('d مايو 2025', 'ar').format(now), style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(width: 15),
        Icon(FluentIcons.calendar, size: 16, color: Colors.grey),
        SizedBox(width: 15),
        Text(DateFormat('hh:mm a').format(now), style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(width: 8),
        Icon(FluentIcons.clock, size: 16, color: Colors.grey),
      ],
    );
  }

  Widget _buildUserProfile(user) {
    return Row(
      children: [
        Icon(FluentIcons.chevron_down, size: 8, color: Colors.grey),
        SizedBox(width: 12),
        material.CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.mainBg,
          child: Icon(FluentIcons.contact, color: AppColors.sidebarBg, size: 20),
        ),
        SizedBox(width: 12),
        Column(
          mainAxisAlignment: material.MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.fullName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(user.role, style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  List<NavigationPaneItem> _getPaneItems(Widget child) {
    final user = ref.read(authControllerProvider).user;
    final body = material.Directionality(
      textDirection: material.TextDirection.rtl,
      child: Column(
        children: [
          _buildTopAppBar(user),
          Expanded(child: Container(color: AppColors.mainBg, child: child)),
          _buildLicenseFooter(),
        ],
      ),
    );

    return [
      _item(FluentIcons.home, "الرئيسية", Colors.orange, body),
      _item(FluentIcons.product, "المنتجات", Colors.purple, body),
      _item(FluentIcons.product_variant, "الأقسام", Colors.blue, body),
      _item(FluentIcons.product_release, "المخازن", Colors.teal, body),
      _item(FluentIcons.all_apps, "المخزون", Color(0xFF3F51B5), body),
      _item(FluentIcons.shopping_cart, "المبيعات", Colors.blue, body),
      _item(FluentIcons.receipt_check, "المشتريات", Colors.orange, body),
      _item(FluentIcons.people, "العملاء", material.Color(0xFFE91E63), body),
      _item(FluentIcons.delivery_truck, "الموردين", Colors.red, body),
      _item(FluentIcons.report_document, "التقارير", Colors.yellow, body),
      _item(FluentIcons.action_center, "التنبيهات", Colors.orange, body),
      _item(FluentIcons.contact, "المستخدمين", Colors.green, body),
      _item(FluentIcons.settings, "الإعدادات", Colors.grey, body),
      _item(FluentIcons.verified_brand, "الترخيص", Colors.yellow, body),
    ];
  }

  NavigationPaneItem _item(IconData icon, String title, Color color, Widget body) {
    return PaneItem(
      icon: Icon(icon, color: color, size: 20),
      title: Text(title, style: TextStyle(color: Colors.white)),
      body: body,
    );
  }

  void _onItemTapped(int index, BuildContext context) {
    final routes = [
      '/dashboard', '/products', '/categories', '/warehouses', '/inventory',
      '/sales', '/purchases', '/customers', '/suppliers', '/reports',
      '/alerts', '/users', '/settings', '/license-management'
    ];
    if (index < routes.length) {
       context.go(routes[index]);
    }
  }

  void _handleLogout(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        title: Text('تسجيل الخروج'),
        content: Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          FilledButton(
            child: Text('خروج'),
            onPressed: () => Navigator.pop(context, 'logout'),
          ),
          Button(
            child: Text('إلغاء'),
            onPressed: () => Navigator.pop(context, 'cancel'),
          ),
        ],
      ),
    );

    if (result == 'logout') {
      ref.read(authControllerProvider.notifier).logout();
      if (mounted) GoRouter.of(context).go('/login');
    }
  }

  Widget _buildLicenseFooter() {
    return Container(
      width: double.infinity,
      height: 30,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           Text("CASHIER PRO | نسخة مرخصة", style: TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}
