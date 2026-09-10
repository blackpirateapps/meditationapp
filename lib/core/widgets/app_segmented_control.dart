import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../haptics/haptic_service.dart';

class AppSegmentedControl<T> extends StatelessWidget {
  final Map<T, String> items;
  final T selectedValue;
  final ValueChanged<T> onValueChanged;

  const AppSegmentedControl({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: context.surfaceSubtleColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: items.entries.map((entry) {
          final isSelected = entry.key == selectedValue;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (!isSelected) {
                  HapticService.selection();
                  onValueChanged(entry.key);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? context.surfaceColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  entry.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    letterSpacing: -0.1,
                    color: isSelected
                        ? context.textPrimaryColor
                        : context.textSecondaryColor,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
