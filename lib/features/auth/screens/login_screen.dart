import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controller/auth_controller.dart';
import '../../dashboard/screens/dashboard_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final userController = TextEditingController();
  final passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    return NavigationView(
      content: Center(
        child: Container(
          width: 400,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("OilMaster Pro - دخول", 
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),
                  TextBox(
                    controller: userController,
                    placeholder: "اسم المستخدم",
                    prefix: Padding(padding: EdgeInsets.all(8.0), child: Icon(FluentIcons.contact)),
                  ),
                  const SizedBox(height: 15),
                  PasswordBox(
                    controller: passController,
                    placeholder: "كلمة المرور",
                  ),
                  const SizedBox(height: 30),
                  if (state.error != null) 
                    Text(state.error!, style: TextStyle(color: Colors.red)),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      child: state.isLoading ? const ProgressRing() : const Text("تسجيل الدخول"),
                      onPressed: () async {
                        final success = await ref.read(authControllerProvider.notifier)
                            .login(userController.text, passController.text);
                        if (success) {
                          context.go('/dashboard');
                        }
                      },
                    ),
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
