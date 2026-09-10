import 'package:flutter/material.dart';
import 'app_surface.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20.0),
    this.margin,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: padding,
      margin: margin,
      borderRadius: 18.0,
      color: color,
      onTap: onTap,
      child: child,
    );
  }
}
