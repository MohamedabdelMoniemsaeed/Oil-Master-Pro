import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;

import '../../../core/services/service_locator.dart';
import '../../../database/database.dart';
import '../../../repositories/settings_repository.dart';
import '../../../core/services/backup_service.dart';
import '../../../core/services/license_service.dart';
import '../../../core/services/license_notification_service.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/services/notification_service.dart';
import '../../auth/controller/auth_controller.dart';
import '../../products/controller/products_controller.dart';
import '../../customers/controller/customers_controller.dart';
import '../../purchases/controller/purchases_controller.dart';
import '../../sales/screens/invoices_screen.dart';
import '../../alerts/controller/alerts_controller.dart';
import '../../reports/controller/reports_controller.dart';
import '../../warehouses/controller/warehouses_controller.dart';
import 'license_screen.dart';
import '../../../core/widgets/app_back_button.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({
    super.key,
  });

  @override
  ConsumerState<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState
    extends ConsumerState<SettingsScreen> {
  final shopName = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();
  String? logoPath;

  final repository = getIt<SettingsRepository>();

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final data = await repository.getSettings();
    if(data != null){
      shopName.text = data.shopName;
      phone.text = data.phone ?? "";
      address.text = data.address ?? "";
      setState(() {
        logoPath = data.logo;
      });
    }
  }

  Future<void> pickLogo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        logoPath = result.files.single.path;
      });
    }
  }

  Future<void> save() async {
    final currentUser = ref.read(authControllerProvider).user;
    if (currentUser?.role != 'admin') {
      NotificationService.showError(context, "خطأ", "ليس لديك صلاحية لتعديل بيانات المحل.");
      return;
    }

    final old = await repository.getSettings();
    if(old == null){
      await repository.saveSettings(
        SettingsTableCompanion(
          shopName: Value(shopName.text),
          phone: Value(phone.text),
          address: Value(address.text),
          logo: Value(logoPath),
        ),
        user: currentUser,
      );
    }else{
      await repository.updateSettings(
        old.copyWith(
          shopName: shopName.text,
          phone: Value(phone.text),
          address: Value(address.text),
          logo: Value(logoPath),
        ),
        user: currentUser,
      );
    }

    if (mounted) {
      NotificationService.showSuccess(context, "تم حفظ الإعدادات", null);
    }
  }

  void _handleBackup() async {
    final currentUser = ref.read(authControllerProvider).user;
    try {
      final success = await BackupService.createBackup(user: currentUser);
      if (success && mounted) {
        NotificationService.showSuccess(context, "نجاح", "تم إنشاء النسخة الاحتياطية بنجاح");
      }
    } catch (e) {
      if (mounted) NotificationService.showError(context, "خطأ", e.toString().replaceAll("Exception: ", ""));
    }
  }

  void _handleRestore() async {
    final currentUser = ref.read(authControllerProvider).user;
    if (!PermissionService.canRestore(currentUser)) {
      NotificationService.showError(context, "خطأ", "ليس لديك صلاحية لاستعادة النسخ الاحتياطية.");
      return;
    }

    final confirm = await NotificationService.showConfirmDialog(
      context, 
      "تأكيد الاستعادة", 
      "تحذير: سيتم استبدال قاعدة البيانات الحالية بالكامل وحذف جميع البيانات الحالية لصالح النسخة الاحتياطية. هل أنت متأكد؟ سيتم إغلاق البرنامج بعد العملية."
    );

    if (confirm == true) {
      try {
        final success = await BackupService.restoreBackup(user: currentUser);
        if (success && mounted) {
          await showDialog(
            context: context,
            builder: (context) => ContentDialog(
              title: const Text("تمت الاستعادة بنجاح"),
              content: const Text("تمت استعادة البيانات بنجاح. سيتم إغلاق البرنامج الآن لتطبيق التغييرات. يرجى إعادة تشغيله يدوياً."),
              actions: [
                FilledButton(
                  child: const Text("حسناً"),
                  onPressed: () => exit(0),
                )
              ],
            ),
          );
        }
      } catch (e) {
        if (mounted) NotificationService.showError(context, "خطأ في الاستعادة", e.toString());
      }
    }
  }

  void _handleResetData() async {
    final authState = ref.read(authControllerProvider);
    if (authState.user?.role != 'admin') {
      NotificationService.showError(context, "خطأ", "هذا الإجراء مخصص لمدير النظام فقط");
      return;
    }

    final confirm1 = await NotificationService.showConfirmDialog(
      context, 
      "مسح جميع البيانات", 
      "تحذير: سيتم حذف جميع بيانات المنتجات والمبيعات والمشتريات والعملاء والمخازن الحالية ولا يمكن التراجع عن العملية. هل أنت متأكد؟"
    );

    if (confirm1 == true) {
      final confirm2 = await NotificationService.showConfirmDialog(
        context, 
        "تأكيد نهائي", 
        "هل أنت متأكد حقاً من مسح كافة البيانات التشغيلية؟"
      );

      if (confirm2 == true) {
        try {
          await repository.clearOperationalData();
          
          if (mounted) {
            NotificationService.showSuccess(context, "نجاح", "تم مسح كافة البيانات التشغيلية بنجاح. النظام الآن جاهز للبدء من جديد.");
            
            // تحديث كافة الـ Providers لتعكس البيانات الفارغة
            ref.invalidate(productsControllerProvider);
            ref.invalidate(customersControllerProvider);
            ref.invalidate(purchasesControllerProvider);
            ref.invalidate(invoicesProvider);
            ref.invalidate(alertsControllerProvider);
            ref.invalidate(reportsControllerProvider);
            ref.invalidate(warehousesControllerProvider);
          }
        } catch (e) {
          if (mounted) NotificationService.showError(context, "خطأ", "فشل مسح البيانات: $e");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authControllerProvider).user;
    final bool isAdmin = currentUser?.role == 'admin';

    return ScaffoldPage(
      header: const PageHeader(
        leading: AppBackButton(),
        title: Text("إعدادات النظام والنسخ الاحتياطي"),
      ),
      content: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("بيانات المحل", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Card(
              child: Column(
                children: [
                  TextBox(controller: shopName, placeholder: "اسم المحل", readOnly: !isAdmin),
                  const SizedBox(height: 10),
                  TextBox(controller: phone, placeholder: "رقم الهاتف", readOnly: !isAdmin),
                  const SizedBox(height: 10),
                  TextBox(controller: address, placeholder: "العنوان", readOnly: !isAdmin),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: logoPath != null && File(logoPath!).existsSync()
                            ? Image.file(File(logoPath!), width: 80, height: 80, fit: BoxFit.cover)
                            : Image.asset('assets/images/Logo2.png', width: 80, height: 80, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 15),
                      if (isAdmin)
                        Button(
                          child: const Text("تغيير شعار المحل"),
                          onPressed: pickLogo,
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (isAdmin)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        child: const Text("حفظ التغييرات"),
                        onPressed: save,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text("أدوات البيانات", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Card(
              child: Row(
                children: [
                  Expanded(
                    child: Button(
                      onPressed: PermissionService.canBackup(currentUser) ? _handleBackup : null,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(FluentIcons.database_source, size: 30),
                          const SizedBox(height: 8),
                          const Text("إنشاء نسخة احتياطية"),
                        ],
                      ),
                    ),
                  ),
                  if (PermissionService.canRestore(currentUser)) ...[
                    const SizedBox(width: 15),
                    Expanded(
                      child: Button(
                        onPressed: _handleRestore,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(FluentIcons.database_sync, size: 30, color: Colors.orange),
                            const SizedBox(height: 8),
                            const Text("استعادة نسخة احتياطية"),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isAdmin) ...[
              const SizedBox(height: 15),
              Card(
                child: SizedBox(
                  width: double.infinity,
                  child: Button(
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.all(Colors.red),
                    ),
                    onPressed: _handleResetData,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(FluentIcons.delete),
                          SizedBox(width: 10),
                          Text("مسح البيانات التجريبية والبدء من جديد", style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 30),
            _buildLicenseInfo(currentUser),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseInfo(UsersTableData? user) {
    return FutureBuilder<AppLicenseInfo>(
      future: LicenseService.getLicenseInfo(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final license = snapshot.data!;
        final expiry = license.expiryDate;
        final licenseStatus = LicenseNotificationService.getLicenseMessage(expiry, type: license.type);
        final statusColor = LicenseNotificationService.isCritical(expiry)
            ? Colors.red
            : LicenseNotificationService.shouldShowWarning(expiry)
                ? Colors.orange
                : Colors.green;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("معلومات الترخيص", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          LicenseNotificationService.isCritical(expiry)
                              ? FluentIcons.error_badge
                              : FluentIcons.info,
                          color: statusColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            licenseStatus,
                            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    if (expiry != null) ...[
                      const SizedBox(height: 10),
                      Text('تاريخ الانتهاء: ${expiry.toLocal().toString().split(' ')[0]}'),
                    ],
                    if (PermissionService.canManageLicense(user)) ...[
                      const SizedBox(height: 15),
                      FilledButton(
                        child: const Text('إدارة التراخيص والتفعيل'),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            FluentPageRoute(builder: (_) => const LicenseScreen()),
                          );
                          setState(() {});
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    shopName.dispose();
    phone.dispose();
    address.dispose();
    super.dispose();
  }
}
