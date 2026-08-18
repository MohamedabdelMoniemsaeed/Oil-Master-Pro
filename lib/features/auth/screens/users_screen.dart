import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/users_controller.dart';
import 'add_user_screen.dart';
import '../../../database/database.dart';
import '../controller/auth_controller.dart';
import '../../../core/widgets/app_back_button.dart';

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
    final currentUser = ref.watch(authControllerProvider).user;

    return ScaffoldPage(
      header: PageHeader(
        leading: const AppBackButton(),
        title: const Text("إدارة المستخدمين"),
        commandBar: FilledButton(
          onPressed: () => showDialog(
            context: context,
            builder: (context) => const AddUserScreen(),
          ),
          child: const Text("إضافة مستخدم"),
        ),
      ),
      content: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          String roleText = "كاشير";
          if (user.role == 'admin') roleText = "مدير نظام";
          if (user.role == 'supervisor') roleText = "مشرف";

          final bool isTargetAdmin = user.role == 'admin';
          final bool canDelete = currentUser?.role == 'admin' || (currentUser?.role == 'supervisor' && !isTargetAdmin);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: ListTile(
              title: Text(user.fullName),
              subtitle: Text("اسم المستخدم: ${user.username} | الصلاحية: $roleText"),
              trailing: canDelete && user.id != currentUser?.id ? IconButton(
                icon: Icon(FluentIcons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(user),
              ) : null,
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(UsersTableData user) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('حذف المستخدم'),
        content: Text('هل أنت متأكد من حذف المستخدم "${user.fullName}"؟'),
        actions: [
          Button(child: const Text('إلغاء'), onPressed: () => Navigator.pop(context)),
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.red)),
            onPressed: () async {
              await ref.read(usersControllerProvider.notifier).deleteUser(user.id);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
