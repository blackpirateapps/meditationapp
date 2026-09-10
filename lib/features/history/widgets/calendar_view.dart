import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/haptics/haptic_service.dart';

class CalendarView extends StatelessWidget {
  final DateTime currentMonth;
  final Set<DateTime> activeDates;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<DateTime> onMonthChanged;

  const CalendarView({
    super.key,
    required this.currentMonth,
    required this.activeDates,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(
      currentMonth.year,
      currentMonth.month,
    );
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final startingWeekday = firstDayOfMonth.weekday; // 1 = Mon, 7 = Sun

    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return Column(
      children: [
        // Month Navigation Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: () {
                final prev = DateTime(currentMonth.year, currentMonth.month - 1, 1);
                onMonthChanged(prev);
              },
            ),
            Text(
              '${monthNames[currentMonth.month - 1]} ${currentMonth.year}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.textPrimaryColor,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed: () {
                final next = DateTime(currentMonth.year, currentMonth.month + 1, 1);
                onMonthChanged(next);
              },
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Day of Week Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((d) {
            return SizedBox(
              width: 36,
              child: Text(
                d,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.textTertiaryColor,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),

        // Days Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.0,
          ),
          itemCount: (startingWeekday - 1) + daysInMonth,
          itemBuilder: (ctx, index) {
            if (index < startingWeekday - 1) {
              return const SizedBox();
            }

            final day = index - (startingWeekday - 1) + 1;
            final date = DateTime(currentMonth.year, currentMonth.month, day);
            final isSelected = selectedDate != null &&
                DateUtils.isSameDay(selectedDate!, date);

            final hasSession = activeDates.any((d) => DateUtils.isSameDay(d, date));

            return GestureDetector(
              onTap: () {
                HapticService.selection();
                onDateSelected(date);
              },
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? context.accentColor
                      : (hasSession
                          ? context.accentColor.withValues(alpha: 0.15)
                          : Colors.transparent),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected || hasSession
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected
                            ? Colors.white
                            : (hasSession
                                ? context.accentColor
                                : context.textPrimaryColor),
                      ),
                    ),
                    if (hasSession && !isSelected)
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.accentColor,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
