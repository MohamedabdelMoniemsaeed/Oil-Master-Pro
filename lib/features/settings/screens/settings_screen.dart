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
import 'license_screen.dart';

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


  final shopName =
      TextEditingController();
  final phone =
      TextEditingController();
  final address =
      TextEditingController();
  String? logoPath;

  final repository =
      getIt<SettingsRepository>();

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final data =
        await repository.getSettings();
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
    final old =
        await repository.getSettings();
    if(old == null){
      await repository.saveSettings(
        SettingsTableCompanion(
          shopName: Value(shopName.text),
          phone: Value(phone.text),
          address: Value(address.text),
          logo: Value(logoPath),
        ),
      );
    }else{
      await repository.updateSettings(
        old.copyWith(
          shopName: shopName.text,
          phone: Value(phone.text),
          address: Value(address.text),
          logo: Value(logoPath),
        ),
      );
    }



    displayInfoBar(

      context,

      builder: (_,close){

        return const InfoBar(

          title:
          Text(
            "تم حفظ الإعدادات",
          ),

          severity:
          InfoBarSeverity.success,

        );

      },

    );


  }





  @override
  Widget build(BuildContext context) {


    return ScaffoldPage(


      header: PageHeader(
        leading: IconButton(
          icon: const Icon(FluentIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "إعدادات المحل",
        ),
      ),



      content: Column(

        children: [


          TextBox(

            controller:
            shopName,

            placeholder:
            "اسم المحل",

          ),



          const SizedBox(
            height: 10,
          ),



          TextBox(

            controller:
            phone,

            placeholder:
            "رقم الهاتف",

          ),



          const SizedBox(
            height: 10,
          ),



          TextBox(
            controller: address,
            placeholder: "العنوان",
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (logoPath != null)
                Image.file(File(logoPath!), width: 100, height: 100),
              const SizedBox(width: 10),
              Button(
                child: const Text("اختيار شعار المحل"),
                onPressed: pickLogo,
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton(
            child: const Text("حفظ"),
            onPressed: save,
          ),
          const SizedBox(height: 40),
          const Text("النسخ الاحتياطي",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              Button(
                child: const Text("إنشاء نسخة احتياطية"),
                onPressed: () async {
                  final success = await BackupService.createBackup();
                  if (success) {
                    displayInfoBar(context, builder: (_, close) {
                      return const InfoBar(
                          title: Text("تم إنشاء النسخة الاحتياطية بنجاح"),
                          severity: InfoBarSeverity.success);
                    });
                  }
                },
              ),
              const SizedBox(width: 10),
              Button(
                child: const Text("استعادة نسخة احتياطية"),
                onPressed: () async {
                  final success = await BackupService.restoreBackup();
                  if (success) {
                    displayInfoBar(context, builder: (_, close) {
                      return const InfoBar(
                          title: Text("تمت الاستعادة بنجاح. يرجى إعادة تشغيل البرنامج."),
                          severity: InfoBarSeverity.warning);
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 40),
          FutureBuilder(
            future: repository.getSettings(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }
              final settings = snapshot.data;
              final licenseStatus = LicenseNotificationService.getLicenseMessage(settings?.expiryDate);
              final statusColor = LicenseNotificationService.isCritical(settings?.expiryDate)
                  ? Colors.red
                  : LicenseNotificationService.shouldShowWarning(settings?.expiryDate)
                      ? Colors.orange
                      : Colors.green;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "معلومات الترخيص",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                LicenseNotificationService.isCritical(settings?.expiryDate)
                                    ? FluentIcons.error_badge
                                    : FluentIcons.info,
                                color: statusColor,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  licenseStatus,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (settings?.expiryDate != null)
                            Row(
                              children: [
                                const Text(
                                  'تاريخ الانتهاء: ',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  settings!.expiryDate!.toLocal().toString().split(' ')[0],
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          const SizedBox(height: 16),
                          if (LicenseNotificationService.shouldShowWarning(settings?.expiryDate))
                            FilledButton(
                              child: const Text('جدّد الترخيص الآن'),
                              onPressed: () async {
                                final result = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => const LicenseScreen(),
                                );
                                if (result == true) {
                                  setState(() {});
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }





  @override
  void dispose(){

    shopName.dispose();

    phone.dispose();

    address.dispose();


    super.dispose();

  }

}