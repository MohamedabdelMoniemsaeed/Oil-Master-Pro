import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../database/database.dart';
import '../controller/users_controller.dart';

import '../controller/auth_controller.dart';

class AddUserScreen extends ConsumerStatefulWidget {
  const AddUserScreen({super.key});

  @override
  ConsumerState<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends ConsumerState<AddUserScreen> {
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  String selectedRole = 'cashier';

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authControllerProvider).user;

    return ContentDialog(
      title: const Text('إضافة مستخدم جديد'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextBox(
            controller: nameController,
            placeholder: 'الاسم الكامل',
          ),
          const SizedBox(height: 10),
          TextBox(
            controller: usernameController,
            placeholder: 'اسم المستخدم',
          ),
          const SizedBox(height: 10),
          PasswordBox(
            controller: passwordController,
            placeholder: 'كلمة المرور',
          ),
          const SizedBox(height: 10),
          ComboBox<String>(
            value: selectedRole,
            items: [
              if (currentUser?.role == 'admin')
                const ComboBoxItem(value: 'admin', child: Text('مدير نظام')),
              const ComboBoxItem(value: 'supervisor', child: Text('مشرف محل')),
              const ComboBoxItem(value: 'cashier', child: Text('كاشير')),
            ],
            onChanged: (val) => setState(() => selectedRole = val ?? 'cashier'),
          ),
        ],
      ),
      actions: [
        Button(
          child: const Text('إلغاء'),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          child: const Text('حفظ'),
          onPressed: () async {
            if (nameController.text.isEmpty || usernameController.text.isEmpty) return;
            
            await ref.read(usersControllerProvider.notifier).addUser(
              UsersTableCompanion.insert(
                fullName: nameController.text,
                username: usernameController.text,
                password: passwordController.text,
                role: drift.Value(selectedRole),
              ),
            );
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
