import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? color;
  final Border? border;
  final VoidCallback? onTap;

  const AppSurface({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16.0,
    this.color,
    this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? context.surfaceColor;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      side: BorderSide(color: context.borderColor, width: 0.8),
    );

    Widget surface = Material(
      color: bg,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              child: Padding(
                padding: padding ?? const EdgeInsets.all(16.0),
                child: child,
              ),
            )
          : Padding(
              padding: padding ?? const EdgeInsets.all(16.0),
              child: child,
            ),
    );

    if (margin != null) {
      return Padding(padding: margin!, child: surface);
    }

    return surface;
  }
}
