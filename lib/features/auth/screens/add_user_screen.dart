import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../database/database.dart';
import '../controller/users_controller.dart';

class AddUserScreen extends ConsumerStatefulWidget {
  const AddUserScreen({super.key});

  @override
  ConsumerState<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends ConsumerState<AddUserScreen> {
  final userController = TextEditingController();
  final passController = TextEditingController();
  final nameController = TextEditingController();
  String role = 'cashier';

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('إضافة مستخدم جديد'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextBox(
            controller: nameController,
            placeholder: 'الاسم بالكامل',
          ),
          const SizedBox(height: 10),
          TextBox(
            controller: userController,
            placeholder: 'اسم المستخدم',
          ),
          const SizedBox(height: 10),
          PasswordBox(
            controller: passController,
            placeholder: 'كلمة المرور',
          ),
          const SizedBox(height: 15),
          const Text('الصلاحية:'),
          const SizedBox(height: 5),
          ComboBox<String>(
            value: role,
            items: const [
              ComboBoxItem(value: 'admin', child: Text('مدير')),
              ComboBoxItem(value: 'cashier', child: Text('كاشير')),
            ],
            onChanged: (v) => setState(() => role = v ?? 'cashier'),
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
            if (userController.text.isEmpty || passController.text.isEmpty) return;

            await ref.read(usersControllerProvider.notifier).addUser(
                  UsersTableCompanion.insert(
                    username: userController.text,
                    password: passController.text,
                    fullName: nameController.text,
                    role: Value(role),
                  ),
                );
            if (mounted) {
              Navigator.pop(context, true);
            }
          },
        ),
      ],
    );
  }
}
