import 'package:flutter/material.dart';
import '../../../data/models/meditation_type.dart';
import '../../../data/models/meditation_session.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_sheet.dart';

class HistoryFilter {
  final MeditationType? type;
  final SessionStatus? status;
  final int minDurationMinutes;

  const HistoryFilter({
    this.type,
    this.status,
    this.minDurationMinutes = 0,
  });

  bool get isActive =>
      type != null || status != null || minDurationMinutes > 0;

  HistoryFilter copyWith({
    MeditationType? type,
    bool clearType = false,
    SessionStatus? status,
    bool clearStatus = false,
    int? minDurationMinutes,
  }) {
    return HistoryFilter(
      type: clearType ? null : (type ?? this.type),
      status: clearStatus ? null : (status ?? this.status),
      minDurationMinutes: minDurationMinutes ?? this.minDurationMinutes,
    );
  }
}

class HistoryFilterSheet extends StatefulWidget {
  final HistoryFilter initialFilter;
  final ValueChanged<HistoryFilter> onApply;

  const HistoryFilterSheet({
    super.key,
    required this.initialFilter,
    required this.onApply,
  });

  static void show({
    required BuildContext context,
    required HistoryFilter filter,
    required ValueChanged<HistoryFilter> onApply,
  }) {
    AppSheet.show(
      context: context,
      title: 'Filter History',
      child: HistoryFilterSheet(
        initialFilter: filter,
        onApply: onApply,
      ),
    );
  }

  @override
  State<HistoryFilterSheet> createState() => _HistoryFilterSheetState();
}

class _HistoryFilterSheetState extends State<HistoryFilterSheet> {
  late HistoryFilter _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Meditation Type Filter
          Text(
            'Meditation Type',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All Types'),
                selected: _current.type == null,
                onSelected: (s) {
                  if (s) setState(() => _current = _current.copyWith(clearType: true));
                },
              ),
              ...MeditationType.values.map((t) {
                return ChoiceChip(
                  label: Text(t.displayName),
                  selected: _current.type == t,
                  onSelected: (s) {
                    setState(() {
                      _current = s
                          ? _current.copyWith(type: t)
                          : _current.copyWith(clearType: true);
                    });
                  },
                );
              }),
            ],
          ),

          const SizedBox(height: 20),

          // Status Filter
          Text(
            'Completion Status',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _current.status == null,
                onSelected: (s) {
                  if (s) setState(() => _current = _current.copyWith(clearStatus: true));
                },
              ),
              ChoiceChip(
                label: const Text('Completed Only'),
                selected: _current.status == SessionStatus.completed,
                onSelected: (s) {
                  setState(() {
                    _current = s
                        ? _current.copyWith(status: SessionStatus.completed)
                        : _current.copyWith(clearStatus: true);
                  });
                },
              ),
              ChoiceChip(
                label: const Text('Partial Sessions'),
                selected: _current.status == SessionStatus.partial,
                onSelected: (s) {
                  setState(() {
                    _current = s
                        ? _current.copyWith(status: SessionStatus.partial)
                        : _current.copyWith(clearStatus: true);
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Duration Filter
          Text(
            'Minimum Duration',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [0, 5, 10, 20].map((m) {
              return ChoiceChip(
                label: Text(m == 0 ? 'Any' : '$m+ min'),
                selected: _current.minDurationMinutes == m,
                onSelected: (s) {
                  if (s) setState(() => _current = _current.copyWith(minDurationMinutes: m));
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 28),

          Row(
            children: [
              TextButton(
                onPressed: () {
                  setState(() => _current = const HistoryFilter());
                },
                child: const Text('Reset'),
              ),
              const Spacer(),
              AppButton(
                label: 'Apply Filters',
                onPressed: () {
                  widget.onApply(_current);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
