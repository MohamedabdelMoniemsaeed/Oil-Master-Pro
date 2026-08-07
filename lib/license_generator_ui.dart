import 'package:fluent_ui/fluent_ui.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const LicenseGeneratorApp());
}

class LicenseGeneratorApp extends StatelessWidget {
  const LicenseGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'مولد تراخيص OilMaster Pro',
      debugShowCheckedModeBanner: false,
      theme: FluentThemeData(
        brightness: Brightness.light,
        accentColor: Colors.blue,
      ),
      home: const GeneratorScreen(),
    );
  }
}

class GeneratorScreen extends StatefulWidget {
  const GeneratorScreen({super.key});

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  final nameController = TextEditingController();
  String generatedKey = "";

  void _generate() {
    if (nameController.text.trim().isEmpty) return;

    const String salt = "OIL_MASTER_PRO_SECRET";
    var bytes = utf8.encode(nameController.text.trim() + salt);
    setState(() {
      generatedKey = md5.convert(bytes).toString().toUpperCase().substring(0, 16);
    });
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      content: ScaffoldPage(
        header: PageHeader(
          title: Text("مولد مفاتيح تفعيل OilMaster Pro"),
        ),
        content: Center(
          child: Container(
            width: 500,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FluentIcons.entitlement_policy, size: 50, color: Colors.blue),
                    const SizedBox(height: 20),
                    Text("توليد مفتاح جديد",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 30),
                    TextBox(
                      controller: nameController,
                      placeholder: "أدخل اسم محل العميل (بدقة)",
                      onChanged: (v) => setState(() => generatedKey = ""),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _generate,
                        child: const Text("توليد المفتاح"),
                      ),
                    ),
                    if (generatedKey.isNotEmpty) ...[
                      const SizedBox(height: 40),
                      Text("مفتاح الترخيص الخاص بالعميل:"),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.grey[30],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                generatedKey,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(FluentIcons.copy),
                              onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(text: generatedKey));
                                displayInfoBar(context,
                                    builder: (context, close) {
                                  return const InfoBar(
                                    title: Text("تم النسخ"),
                                    severity: InfoBarSeverity.success,
                                  );
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
