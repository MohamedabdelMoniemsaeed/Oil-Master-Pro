import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../../../core/services/license_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/license_provider.dart';

class LicenseScreen extends ConsumerStatefulWidget {
  const LicenseScreen({super.key});

  @override
  ConsumerState<LicenseScreen> createState() => _LicenseScreenState();
}

class _LicenseScreenState extends ConsumerState<LicenseScreen> {
  final keyController = TextEditingController();
  bool activating = false;
  bool showRenewalForm = false;
  String? hardwareId;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final id = await LicenseService.getDeviceId();
    if (mounted) setState(() => hardwareId = id);
  }

  Future<void> _handleActivation() async {
    final key = keyController.text.trim();
    if (key.isEmpty) return;

    // Check if we are replacing an existing active license
    final currentInfo = await LicenseService.getLicenseInfo();
    if (currentInfo.isVerified && currentInfo.status == "Active") {
      final bool? confirm = await NotificationService.showConfirmDialog(
        context,
        "تأكيد الاستبدال",
        "يوجد ترخيص حالي ساري حتى ${DateFormat('yyyy-MM-dd').format(currentInfo.expiryDate!)}. هل تريد استبداله بالترخيص الجديد؟",
      );
      if (confirm != true) return;
    }

    setState(() => activating = true);
    
    try {
      // Perform detailed verification first
      final info = await LicenseService.verifyKeyLocally(key);
      
      if (info.isVerified && info.status == "Active") {
        final success = await LicenseService.activate(key);
        if (success) {
          ref.invalidate(licenseInfoProvider);
          if (mounted) {
            NotificationService.showSuccess(context, "تم التجديد", "تم تجديد الترخيص بنجاح.");
            keyController.clear();
            setState(() => showRenewalForm = false);
            await _loadStatus();
          }
        } else {
          if (mounted) _showDiagnosticDialog(info, "تعذر حفظ بيانات الترخيص في النظام.");
        }
      } else {
        if (mounted) _showDiagnosticDialog(info, "فشل التحقق من مفتاح الترخيص الجديد.");
      }
    } catch (e) {
       final errorInfo = await LicenseService.verifyKeyLocally(key);
       if (mounted) _showDiagnosticDialog(errorInfo, "خطأ تقني أثناء الحفظ: $e");
    } finally {
      if (mounted) setState(() => activating = false);
    }
  }

  void _showDiagnosticDialog(AppLicenseInfo info, String message) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text("تفاصيل التفعيل (Diagnostic)"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message, style: const TextStyle(fontWeight: FontWeight.bold, color: material.Colors.red)),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              _diagItem("Status", info.status),
              _diagItem("HWID (App)", hardwareId ?? "Unknown"),
              _diagItem("HWID (License)", info.deviceId),
              _diagItem("Verified", info.isVerified ? "YES" : "NO"),
              const SizedBox(height: 10),
              const Text("Logs:", style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: material.Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(info.debugLog ?? "No logs available", style: const TextStyle(fontSize: 10, fontFamily: 'monospace')),
              ),
            ],
          ),
        ),
        actions: [
          Button(
            child: const Text("نسخ السجلات"),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: info.debugLog ?? ""));
            },
          ),
          FilledButton(
            child: const Text("إغلاق"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _diagItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Future<void> _startTrial() async {
    final canTrial = await LicenseService.canStartTrial();
    if (!canTrial) {
      NotificationService.showError(context, "خطأ", "لقد تم استخدام الفترة التجريبية مسبقاً على هذا الجهاز.");
      return;
    }

    final success = await LicenseService.activateTrial();
    if (success) {
      ref.invalidate(licenseInfoProvider);
      if (mounted) NotificationService.showSuccess(context, "تم تفعيل الفترة التجريبية", "لديك 30 يوماً لاستخدام كافة مميزات البرنامج.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final licenseAsync = ref.watch(licenseInfoProvider);

    return ScaffoldPage(
      header: const PageHeader(title: Text("نظام الترخيص")),
      content: licenseAsync.when(
        data: (info) => _buildContent(info),
        loading: () => const Center(child: ProgressRing()),
        error: (e, _) => Center(child: Text("خطأ في تحميل بيانات الترخيص: $e")),
      ),
    );
  }

  Widget _buildContent(AppLicenseInfo info) {
    final bool hasValidLicense = info.isVerified && info.status == "Active";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(info),
          const SizedBox(height: 32),
          
          if (hasValidLicense && !showRenewalForm)
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: FilledButton(
                onPressed: () => setState(() => showRenewalForm = true),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text("تجديد / إضافة ترخيص جديد"),
                ),
              ),
            ),

          if (!hasValidLicense || showRenewalForm) ...[
            _buildActivationForm(),
            const SizedBox(height: 32),
          ],
          
          _buildDeviceInfoCard(),
        ],
      ),
    );
  }

  Widget _buildStatusCard(AppLicenseInfo info) {
    final isFull = info.type == LicenseType.full;
    final isTrial = info.type == LicenseType.trial;
    final isExpired = info.type == LicenseType.expired;
    final isNone = info.type == LicenseType.none;

    material.Color statusColor = material.Colors.orange;
    if (isFull && !isExpired) statusColor = material.Colors.green;
    if (isExpired) statusColor = material.Colors.red;
    if (isNone) statusColor = material.Colors.grey;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isFull && !isExpired ? FluentIcons.completed : (isExpired ? FluentIcons.error : FluentIcons.info),
                color: statusColor,
                size: 32,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(info.typeText, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(
                    isExpired ? "صلاحية البرنامج انتهت" : (isFull ? "النسخة مفعلة بالكامل" : (isTrial ? "البرنامج يعمل في الوضع التجريبي" : "البرنامج غير مفعل")),
                    style: TextStyle(color: material.Colors.grey[100]),
                  ),
                ],
              ),
            ],
          ),
          if (info.isVerified) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            _infoRow("اسم العميل:", info.customerName),
            _infoRow("اسم المحل:", info.shopName),
            _infoRow("معرف الترخيص:", info.licenseId),
            _infoRow("تاريخ الإصدار:", info.startDate != null ? DateFormat('yyyy-MM-dd').format(info.startDate!) : "N/A"),
            _infoRow("تاريخ الانتهاء:", info.expiryDate != null ? DateFormat('yyyy-MM-dd').format(info.expiryDate!) : "غير محدد"),
            _infoRow("معرف الجهاز المرخص:", info.deviceId),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isExpired ? "الترخيص منتهي" : "الأيام المتبقية: ${info.daysRemaining} يوم",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildActivationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("تفعيل البرنامج", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        InfoLabel(
          label: "أدخل مفتاح الترخيص:",
          child: Row(
            children: [
              Expanded(
                child: TextBox(
                  controller: keyController,
                  placeholder: "CP1.XXXX.XXXX",
                  maxLines: 3,
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: activating ? null : _handleActivation,
                child: activating ? const material.SizedBox(width: 16, height: 16, child: ProgressRing()) : const Text("تفعيل الآن"),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (hardwareId != null)
           Button(
            onPressed: _startTrial,
            child: const Text("بدء الفترة التجريبية (30 يوم)"),
          ),
      ],
    );
  }

  Widget _buildDeviceInfoCard() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("معلومات الجهاز", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Text("معرف الجهاز (Hardware ID): ${hardwareId ?? 'جاري التحميل...'}")),
              IconButton(
                icon: const Icon(FluentIcons.copy),
                onPressed: hardwareId == null ? null : () {
                  Clipboard.setData(ClipboardData(text: hardwareId!));
                  NotificationService.showInfo(context, "تم النسخ", "تم نسخ معرف الجهاز إلى الحافظة.");
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "يجب تزويد الدعم الفني بهذا المعرف للحصول على مفتاح التفعيل الخاص بك.",
            style: TextStyle(fontSize: 12, color: material.Colors.grey),
          ),
        ],
      ),
    );
  }
}
