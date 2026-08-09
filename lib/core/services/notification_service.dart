import 'package:fluent_ui/fluent_ui.dart';

class NotificationService {
  static void showSuccess(
    BuildContext context,
    String title,
    String? message,
  ) {
    displayInfoBar(
      context,
      builder: (context, close) => InfoBar(
        title: Text(title),
        content: message != null ? Text(message) : null,
        severity: InfoBarSeverity.success,
        onClose: close,
      ),
    );
  }

  static void showError(
    BuildContext context,
    String title,
    String? message,
  ) {
    displayInfoBar(
      context,
      builder: (context, close) => InfoBar(
        title: Text(title),
        content: message != null ? Text(message) : null,
        severity: InfoBarSeverity.error,
        onClose: close,
      ),
    );
  }

  static void showWarning(
    BuildContext context,
    String title,
    String? message,
  ) {
    displayInfoBar(
      context,
      builder: (context, close) => InfoBar(
        title: Text(title),
        content: message != null ? Text(message) : null,
        severity: InfoBarSeverity.warning,
        onClose: close,
      ),
    );
  }

  static void showInfo(
    BuildContext context,
    String title,
    String? message,
  ) {
    displayInfoBar(
      context,
      builder: (context, close) => InfoBar(
        title: Text(title),
        content: message != null ? Text(message) : null,
        severity: InfoBarSeverity.informational,
        onClose: close,
      ),
    );
  }

  static Future<bool?> showConfirmDialog(
    BuildContext context,
    String title,
    String content,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ContentDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          Button(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.pop(context, false),
          ),
          FilledButton(
            child: const Text('موافق'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
  }
}
