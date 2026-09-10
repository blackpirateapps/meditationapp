import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/meditation_session.dart';
import '../../../data/models/practice.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_list_row.dart';
import '../../../core/widgets/app_section_header.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/responsive/breakpoints.dart';
import '../widgets/calendar_view.dart';
import '../widgets/history_filter_sheet.dart';
import 'session_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  final SessionRepository sessionRepo;
  final ValueChanged<Practice>? onStartPractice;

  const HistoryScreen({
    super.key,
    required this.sessionRepo,
    this.onStartPractice,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime? _selectedDate;
  HistoryFilter _filter = const HistoryFilter();
  MeditationSession? _selectedSession;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MeditationSession>>(
      stream: widget.sessionRepo.watchAllSessions(),
      builder: (context, snapshot) {
        final allSessions = snapshot.data ?? [];

        // Apply filters
        var filteredSessions = allSessions.where((s) {
          if (_filter.type != null && s.snapshot.meditationType != _filter.type) {
            return false;
          }
          if (_filter.status != null && s.status != _filter.status) {
            return false;
          }
          if (_filter.minDurationMinutes > 0 &&
              (s.actualDurationSeconds ~/ 60) < _filter.minDurationMinutes) {
            return false;
          }
          if (_selectedDate != null &&
              !DateUtils.isSameDay(s.startedAt, _selectedDate!)) {
            return false;
          }
          return true;
        }).toList();

        final activeDates = allSessions.map((s) => s.startedAt).toSet();

        // Month statistics
        final monthSessions = allSessions.where((s) {
          return s.startedAt.year == _currentMonth.year &&
              s.startedAt.month == _currentMonth.month &&
              s.actualDurationSeconds >= 10;
        }).toList();

        int monthSeconds = 0;
        final Set<int> monthActiveDays = {};
        for (final s in monthSessions) {
          monthSeconds += s.actualDurationSeconds;
          monthActiveDays.add(s.startedAt.day);
        }
        final monthAvg = monthSessions.isNotEmpty
            ? (monthSeconds ~/ monthSessions.length) ~/ 60
            : 0;

        final isTablet = Breakpoints.isTablet(context);

        if (_selectedSession == null && filteredSessions.isNotEmpty) {
          _selectedSession = filteredSessions.first;
        } else if (_selectedSession != null) {
          final idx = filteredSessions.indexWhere((s) => s.id == _selectedSession!.id);
          if (idx != -1) _selectedSession = filteredSessions[idx];
        }

        final mainList = ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: [
            // Month Header & Metrics
            _buildMonthSummaryCard(
              context,
              monthSessions.length,
              monthSeconds ~/ 60,
              monthAvg,
              monthActiveDays.length,
            ),

            const SizedBox(height: 16),

            // Calendar
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: CalendarView(
                currentMonth: _currentMonth,
                activeDates: activeDates,
                selectedDate: _selectedDate,
                onDateSelected: (d) {
                  setState(() {
                    if (_selectedDate != null &&
                        DateUtils.isSameDay(_selectedDate!, d)) {
                      _selectedDate = null; // deselect filter
                    } else {
                      _selectedDate = d;
                    }
                  });
                },
                onMonthChanged: (m) => setState(() => _currentMonth = m),
              ),
            ),

            const SizedBox(height: 24),

            // Session List Header
            AppSectionHeader(
              title: _selectedDate != null
                  ? 'Sessions on ${DateFormat('MMMM d').format(_selectedDate!)}'
                  : 'Sessions',
              trailing: _filter.isActive || _selectedDate != null
                  ? TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedDate = null;
                          _filter = const HistoryFilter();
                        });
                      },
                      child: const Text('Clear Filters'),
                    )
                  : null,
            ),

            if (filteredSessions.isEmpty)
              AppEmptyState(
                icon: Icons.history_rounded,
                title: 'No Sessions Found',
                message: allSessions.isEmpty
                    ? 'Your sessions will appear here after your first practice.'
                    : 'No meditation sessions match the selected filters.',
              )
            else
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: _groupSessionsByDate(filteredSessions, isTablet),
                ),
              ),

            const SizedBox(height: 36),
          ],
        );

        if (isTablet) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('History'),
              actions: [
                IconButton(
                  icon: Icon(
                    _filter.isActive
                        ? Icons.filter_alt_rounded
                        : Icons.filter_alt_outlined,
                    color: _filter.isActive ? context.accentColor : null,
                  ),
                  tooltip: 'Filter',
                  onPressed: () => HistoryFilterSheet.show(
                    context: context,
                    filter: _filter,
                    onApply: (f) => setState(() => _filter = f),
                  ),
                ),
              ],
            ),
            body: AdaptiveTwoPane(
              primaryWidth: 420,
              primary: mainList,
              secondary: _selectedSession != null
                  ? SessionDetailScreen(
                      session: _selectedSession!,
                      sessionRepo: widget.sessionRepo,
                      onDeleted: () => setState(() => _selectedSession = null),
                    )
                  : const AppEmptyState(
                      icon: Icons.notes_rounded,
                      title: 'Select a Session',
                      message: 'Choose a session from history to view details.',
                    ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('History'),
            actions: [
              IconButton(
                icon: Icon(
                  _filter.isActive
                      ? Icons.filter_alt_rounded
                      : Icons.filter_alt_outlined,
                  color: _filter.isActive ? context.accentColor : null,
                ),
                tooltip: 'Filter',
                onPressed: () => HistoryFilterSheet.show(
                  context: context,
                  filter: _filter,
                  onApply: (f) => setState(() => _filter = f),
                ),
              ),
            ],
          ),
          body: mainList,
        );
      },
    );
  }

  Widget _buildMonthSummaryCard(BuildContext context, int count, int totalMin,
      int avgMin, int activeDays) {
    final hours = totalMin ~/ 60;
    final mins = totalMin % 60;
    final timeStr = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('MMMM y').format(_currentMonth).toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
              color: context.accentColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _metricCol('$count', 'Sessions')),
              Expanded(child: _metricCol(timeStr, 'Total Time')),
              Expanded(child: _metricCol('${avgMin}m', 'Average')),
              Expanded(child: _metricCol('$activeDays', 'Active Days')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricCol(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: context.textTertiaryColor,
          ),
        ),
      ],
    );
  }

  List<Widget> _groupSessionsByDate(
      List<MeditationSession> sessions, bool isTablet) {
    final widgets = <Widget>[];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (int i = 0; i < sessions.length; i++) {
      final s = sessions[i];
      final sessionDate =
          DateTime(s.startedAt.year, s.startedAt.month, s.startedAt.day);

      String dateLabel;
      if (DateUtils.isSameDay(sessionDate, today)) {
        dateLabel = 'Today';
      } else if (DateUtils.isSameDay(sessionDate, yesterday)) {
        dateLabel = 'Yesterday';
      } else {
        dateLabel = DateFormat('MMM d').format(sessionDate);
      }

      final isSelected = _selectedSession?.id == s.id;

      widgets.add(
        Container(
          color: isTablet && isSelected
              ? context.accentColor.withValues(alpha: 0.1)
              : Colors.transparent,
          child: AppListRow(
            leading: Icon(
              s.isCompleted
                  ? Icons.check_circle_outline_rounded
                  : Icons.timelapse_rounded,
              size: 20,
              color: s.isCompleted ? Colors.green : Colors.orange,
            ),
            title: '${s.actualDurationSeconds ~/ 60} min · ${s.snapshot.practiceName}',
            subtitle: '$dateLabel · ${DateFormat('h:mm a').format(s.startedAt)}${s.mood != null ? ' · ${_moodEmoji(s.mood!)}' : ''}',
            onTap: () {
              setState(() => _selectedSession = s);
              if (!isTablet) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => SessionDetailScreen(
                      session: s,
                      sessionRepo: widget.sessionRepo,
                    ),
                  ),
                );
              }
            },
          ),
        ),
      );
    }
    return widgets;
  }

  String _moodEmoji(String mood) {
    switch (mood) {
      case 'peaceful':
        return '😌';
      case 'content':
        return '🙂';
      case 'neutral':
        return '😐';
      case 'restless':
        return '😕';
      case 'difficult':
        return '😣';
      default:
        return '😌';
    }
  }
}
