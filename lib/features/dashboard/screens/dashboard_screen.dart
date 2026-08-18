import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_3d_card.dart';
import '../controller/dashboard_controller.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int activeTab = 0; // 0: اليوم, 1: الأسبوع, 2: الشهر

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(dashboardControllerProvider.notifier).loadDashboardStats());
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  _buildQuickActions(),
                  const SizedBox(height: 20),
                  Expanded(child: _buildModulesGrid()),
                ],
              ),
            ),
            const SizedBox(width: 20),
            _buildBestSellingPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        _actionCard("بيع", "إنشاء فاتورة بيع", FluentIcons.tag, AppColors.actionSale, '/sales'),
        const SizedBox(width: 15),
        _actionCard("شراء", "إنشاء فاتورة شراء", FluentIcons.shopping_cart, AppColors.actionPurchase, '/purchases'),
        const SizedBox(width: 15),
        _actionCard("سند", "إنشاء سند قبض/صرف", FluentIcons.all_apps, AppColors.actionVoucher, '/reports'),
        const SizedBox(width: 15),
        _actionCard("إضافة فاتورة جديدة", "إنشاء فاتورة بيع جديدة", FluentIcons.add, AppColors.actionNewInvoice, '/sales'),
      ],
    );
  }

  Widget _actionCard(String title, String sub, IconData icon, Color color, String route) {
    return Expanded(
      child: App3DCard(
        onTap: () => context.go(route),
        child: Container(
          height: 100,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: material.MainAxisAlignment.center,
                children: [
                  Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(sub, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModulesGrid() {
    final modules = [
      {'t': 'المنتجات', 's': 'إدارة المنتجات', 'i': FluentIcons.product, 'c': Colors.teal, 'r': '/products'},
      {'t': 'الأقسام', 's': 'إدارة الأقسام', 'i': FluentIcons.product_variant, 'c': Colors.blue, 'r': '/categories'},
      {'t': 'المخازن', 's': 'إدارة المخازن', 'i': FluentIcons.product_release, 'c': Color(0xFF3F51B5), 'r': '/warehouses'},
      {'t': 'المخزون', 's': 'حركة المخزون', 'i': FluentIcons.all_apps, 'c': Colors.purple, 'r': '/inventory'},
      {'t': 'المبيعات', 's': 'فواتير المبيعات', 'i': FluentIcons.shopping_cart, 'c': Colors.blue, 'r': '/sales'},
      {'t': 'المشتريات', 's': 'فواتير المشتريات', 'i': FluentIcons.receipt_check, 'c': Colors.orange, 'r': '/purchases'},
      {'t': 'العملاء', 's': 'إدارة العملاء', 'i': FluentIcons.people, 'c': Color(0xFFE91E63), 'r': '/customers'},
      {'t': 'الموردين', 's': 'إدارة الموردين', 'i': FluentIcons.delivery_truck, 'c': Color(0xFF00BCD4), 'r': '/suppliers'},
      {'t': 'التقارير', 's': 'التقارير والإحصائيات', 'i': FluentIcons.report_document, 'c': Colors.blue, 'r': '/reports'},
      {'t': 'التنبيهات', 's': 'التنبيهات والإشعارات', 'i': FluentIcons.action_center, 'c': Colors.orange, 'r': '/alerts'},
      {'t': 'المستخدمين', 's': 'إدارة المستخدمين', 'i': FluentIcons.contact, 'c': Color(0xFFE91E63), 'r': '/users'},
      {'t': 'الإعدادات', 's': 'إعدادات النظام', 'i': FluentIcons.settings, 'c': Colors.blue, 'r': '/settings'},
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.6,
      ),
      itemCount: modules.length,
      itemBuilder: (context, i) => _moduleCard(
        modules[i]['t'] as String, 
        modules[i]['s'] as String, 
        modules[i]['i'] as IconData, 
        modules[i]['c'] as Color,
        modules[i]['r'] as String,
      ),
    );
  }

  Widget _moduleCard(String title, String sub, IconData icon, Color color, String route) {
    return App3DCard(
      onTap: () => context.go(route),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: AppColors.shadow.withValues(alpha: 0.1), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: material.MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(sub, style: TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildBestSellingPanel() {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: AppColors.shadow.withValues(alpha: 0.1), blurRadius: 10)],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: material.MainAxisAlignment.center,
            children: [
              Icon(FluentIcons.all_apps, size: 16, color: Colors.blue),
              SizedBox(width: 10),
              Text("الأعلى مبيعاً", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 20),
          _buildTabs(),
          const SizedBox(height: 20),
          Expanded(child: _buildTopProductsList()),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: Button(
              onPressed: () {},
              child: Text("عرض جميع المنتجات"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      height: 40,
      decoration: BoxDecoration(color: AppColors.mainBg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          _tab("اليوم", 0),
          _tab("الأسبوع", 1),
          _tab("الشهر", 2),
        ],
      ),
    );
  }

  Widget _tab(String label, int index) {
    bool active = activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => activeTab = index),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.actionNewInvoice : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label, style: TextStyle(color: active ? Colors.white : Colors.grey, fontWeight: active ? FontWeight.bold : FontWeight.normal)),
        ),
      ),
    );
  }

  Widget _buildTopProductsList() {
    final products = [
      {'n': 'زيت محرك 5W30', 'q': '125', 'c': 1},
      {'n': 'فلتر زيت', 'q': '89', 'c': 2},
      {'n': 'بوجيه NGK', 'q': '65', 'c': 3},
      {'n': 'زيت فرامل', 'q': '48', 'c': 4},
      {'n': 'ماء رادياتير', 'q': '35', 'c': 5},
    ];

    return ListView.separated(
      itemCount: products.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, i) {
        final p = products[i];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: AppColors.mainBg, borderRadius: BorderRadius.circular(8)),
                child: Text("${p['q']}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.sidebarBg)),
              ),
              const SizedBox(width: 15),
              Expanded(child: Text("${p['n']}", style: TextStyle(fontWeight: FontWeight.w500))),
              Icon(FluentIcons.product, color: Colors.blue, size: 16),
              const SizedBox(width: 10),
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.2), shape: BoxShape.circle),
                child: Text("${p['c']}", style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }
}
