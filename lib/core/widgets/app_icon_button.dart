import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../haptics/haptic_service.dart';

class AppIconButton extends StatefulWidget {
  final Widget icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.iconColor,
    this.size = 42.0,
  });

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.backgroundColor ?? context.surfaceSubtleColor;
    final fg = widget.iconColor ?? context.textPrimaryColor;

    Widget button = AnimatedScale(
      scale: _isPressed ? 0.92 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: GestureDetector(
        onTapDown: widget.onPressed != null
            ? (_) {
                setState(() => _isPressed = true);
                HapticService.selection();
              }
            : null,
        onTapUp: widget.onPressed != null
            ? (_) => setState(() => _isPressed = false)
            : null,
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: IconTheme(
              data: IconThemeData(color: fg, size: widget.size * 0.52),
              child: widget.icon,
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }
    return button;
  }
}
