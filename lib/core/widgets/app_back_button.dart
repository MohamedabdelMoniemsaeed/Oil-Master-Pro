import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/dashboard/controller/dashboard_controller.dart';

class AppBackButton extends ConsumerWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool canPop = Navigator.canPop(context);
    final int currentIndex = ref.watch(dashboardIndexProvider);
    
    // Don't show if we are on the home dashboard and cannot pop
    if (!canPop && currentIndex == 0) {
      return const SizedBox.shrink();
    }

    return Tooltip(
      message: "رجوع",
      child: IconButton(
        icon: const Icon(FluentIcons.back, size: 14),
        onPressed: () {
          if (canPop) {
            Navigator.pop(context);
          } else {
            // If in a sidebar section, go back to Dashboard Home
            ref.read(dashboardIndexProvider.notifier).state = 0;
          }
        },
      ),
    );
  }
}
