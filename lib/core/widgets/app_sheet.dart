import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppSheet extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget child;

  const AppSheet({
    super.key,
    required this.title,
    this.trailing,
    required this.child,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    Widget? trailing,
    required Widget child,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => AppSheet(
        title: title,
        trailing: trailing,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: context.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                        color: context.textPrimaryColor,
                      ),
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: context.dividerColor),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}
