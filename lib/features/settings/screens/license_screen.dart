import 'package:fluent_ui/fluent_ui.dart';
import '../../../core/services/license_service.dart';
import '../../auth/screens/login_screen.dart';

class LicenseScreen extends StatefulWidget {
  const LicenseScreen({super.key});

  @override
  State<LicenseScreen> createState() => _LicenseScreenState();
}

class _LicenseScreenState extends State<LicenseScreen> {
  final keyController = TextEditingController();
  String? error;

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      content: Center(
        child: Container(
          width: 500,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(FluentIcons.lock, size: 50),
                  const SizedBox(height: 20),
                  Text("تنشيط البرنامج", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text("البرنامج غير مفعل. يرجى إدخال مفتاح الترخيص الخاص بك."),
                  const SizedBox(height: 8),
                  Text(
                    "المفتاح الخاص بمتجر زيت: ${LicenseService.demoLicenseKey}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 25),
                  TextBox(
                    controller: keyController,
                    placeholder: "مفتاح الترخيص (License Key)",
                  ),
                  const SizedBox(height: 20),
                  if (error != null) Text(error!, style: TextStyle(color: Colors.red)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FilledButton(
                        child: const Text("تنشيط الآن"),
                        onPressed: () async {
                          final success = await LicenseService.activate(keyController.text);
                          if (success) {
                            Navigator.pushReplacement(context, FluentPageRoute(builder: (_) => const LoginScreen()));
                          } else {
                            setState(() => error = "المفتاح غير صحيح");
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
