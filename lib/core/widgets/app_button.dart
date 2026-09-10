import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import '../haptics/haptic_service.dart';

enum AppButtonVariant { primary, secondary, outline, destructive }

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final Widget? icon;
  final bool fullWidth;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.fullWidth = false,
    this.isLoading = false,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Border? border;

    switch (widget.variant) {
      case AppButtonVariant.primary:
        bg = context.accentColor;
        fg = Colors.white;
        break;
      case AppButtonVariant.secondary:
        bg = context.surfaceSubtleColor;
        fg = context.textPrimaryColor;
        break;
      case AppButtonVariant.outline:
        bg = Colors.transparent;
        fg = context.textPrimaryColor;
        border = Border.all(color: context.borderColor, width: 1.0);
        break;
      case AppButtonVariant.destructive:
        bg = AppColors.subtleDestructive.withValues(alpha: 0.12);
        fg = AppColors.subtleDestructive;
        border = Border.all(
          color: AppColors.subtleDestructive.withValues(alpha: 0.3),
          width: 1.0,
        );
        break;
    }

    Widget content = Row(
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (widget.icon != null) ...[
          widget.icon!,
          const SizedBox(width: 8),
        ],
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
            color: fg,
          ),
        ),
      ],
    );

    return AnimatedScale(
      scale: _isPressed ? 0.97 : 1.0,
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
          width: widget.fullWidth ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: widget.onPressed == null ? bg.withValues(alpha: 0.4) : bg,
            borderRadius: BorderRadius.circular(14),
            border: border,
          ),
          child: content,
        ),
      ),
    );
  }
}
