import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/users_controller.dart';
import 'add_user_screen.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(usersControllerProvider.notifier).loadUsers());
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(usersControllerProvider);

    return ScaffoldPage(
      header: PageHeader(
        title: const Text("إدارة المستخدمين"),
        commandBar: FilledButton(
          child: const Text("إضافة مستخدم"),
          onPressed: () => showDialog(
            context: context,
            builder: (context) => const AddUserScreen(),
          ),
        ),
      ),
      content: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(user.fullName),
              subtitle: Text("اسم المستخدم: ${user.username} | الصلاحية: ${user.role == 'admin' ? 'مدير' : 'كاشير'}"),
              trailing: IconButton(
                icon: Icon(FluentIcons.delete, color: Colors.red),
                onPressed: () => ref.read(usersControllerProvider.notifier).deleteUser(user.id),
              ),
            ),
          );
        },
      ),
    );
  }
}
