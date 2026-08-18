import 'package:fluent_ui/fluent_ui.dart';
import '../theme/app_design_system.dart';

class App3DCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const App3DCard({
    super.key,
    required this.child,
    this.onTap,
    this.width,
    this.height,
    this.padding,
  });

  @override
  State<App3DCard> createState() => _App3DCardState();
}

class _App3DCardState extends State<App3DCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = FluentTheme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: widget.width,
          height: widget.height,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF252525) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.15 : 0.05),
                blurRadius: _isHovered ? 20 : 10,
                offset: Offset(0, _isHovered ? 10 : 4),
              )
            ],
          ),
          transform: _isHovered 
              ? (Matrix4.identity()..translate(0.0, -5.0, 0.0))
              : Matrix4.identity(),
          child: widget.child,
        ),
      ),
    );
  }
}
