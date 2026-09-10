import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';

class ActivityChart extends StatelessWidget {
  final Map<DateTime, int> dailyMinutes;
  final String period; // 'week', 'month', 'year', 'allTime'

  const ActivityChart({
    super.key,
    required this.dailyMinutes,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    // Generate data points for the selected period
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysCount = period == 'week' ? 7 : (period == 'month' ? 30 : 14);

    final entries = <MapEntry<DateTime, int>>[];
    for (int i = daysCount - 1; i >= 0; i--) {
      final d = today.subtract(Duration(days: i));
      final mins = dailyMinutes[d] ?? 0;
      entries.add(MapEntry(d, mins));
    }

    final maxMinutes = entries.map((e) => e.value).fold(0, max);
    final chartMax = max(maxMinutes, 30);

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'MINUTES MEDITATED',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                    color: context.textTertiaryColor,
                  ),
                ),
              ),
              Text(
                'Max $chartMax min',
                style: TextStyle(
                  fontSize: 12,
                  color: context.textTertiaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: entries.map((entry) {
                final heightFactor = (entry.value / chartMax).clamp(0.04, 1.0);
                final isToday = DateUtils.isSameDay(entry.key, today);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (entry.value > 0)
                          Text(
                            '${entry.value}',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: context.accentColor,
                            ),
                          ),
                        Container(
                          height: 90 * heightFactor,
                          decoration: BoxDecoration(
                            color: entry.value > 0
                                ? (isToday
                                    ? context.accentColor
                                    : context.accentColor.withValues(alpha: 0.6))
                                : context.surfaceSubtleColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          period == 'week'
                              ? DateFormat('E').format(entry.key).substring(0, 1)
                              : DateFormat('d').format(entry.key),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                            color: isToday
                                ? context.textPrimaryColor
                                : context.textTertiaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
