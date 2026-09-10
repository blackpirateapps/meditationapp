import 'package:flutter/material.dart';
import '../../../data/models/meditation_session.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../data/repositories/achievement_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_segmented_control.dart';
import '../../../core/widgets/app_stat.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/responsive/breakpoints.dart';
import '../widgets/activity_chart.dart';
import '../../achievements/screens/achievements_screen.dart';

class ProgressScreen extends StatefulWidget {
  final SessionRepository sessionRepo;
  final AchievementRepository achievementRepo;

  const ProgressScreen({
    super.key,
    required this.sessionRepo,
    required this.achievementRepo,
  });

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  String _selectedPeriod = 'week';

  String _formatTotalTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Breakpoints.isTablet(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.military_tech_outlined),
            tooltip: 'Milestones',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => AchievementsScreen(
                    achievementRepo: widget.achievementRepo,
                    sessionRepo: widget.sessionRepo,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<MeditationSession>>(
        stream: widget.sessionRepo.watchAllSessions(),
        builder: (context, snapshot) {
          final allSessions = snapshot.data ?? [];
          final stats = widget.sessionRepo.calculateStats(
            allSessions,
            period: _selectedPeriod,
          );

          final periodSelector = Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: AppSegmentedControl<String>(
              items: const {
                'week': 'Week',
                'month': 'Month',
                'year': 'Year',
                'allTime': 'All Time',
              },
              selectedValue: _selectedPeriod,
              onValueChanged: (v) => setState(() => _selectedPeriod = v),
            ),
          );

          final metricsGrid = GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            children: [
              AppStat(
                label: 'Total Time',
                value: _formatTotalTime(stats.totalSeconds),
                icon: Icons.hourglass_top_rounded,
              ),
              AppStat(
                label: 'Sessions',
                value: '${stats.totalSessions}',
                icon: Icons.check_circle_outline_rounded,
              ),
              AppStat(
                label: 'Average',
                value: '${stats.averageSeconds ~/ 60}m',
                icon: Icons.av_timer_rounded,
              ),
              AppStat(
                label: 'Days Meditated',
                value: '${stats.daysMeditated}',
                icon: Icons.calendar_today_rounded,
              ),
            ],
          );

          final streaksCard = AppCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.amber.withValues(alpha: 0.15),
                  ),
                  child: const Icon(Icons.bolt_rounded, color: Colors.amber),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${stats.currentStreak} Day Practice Streak',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Longest streak: ${stats.longestStreak} days',
                        style: TextStyle(
                          fontSize: 13,
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );

          final typeBreakdown = AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PRACTICE BREAKDOWN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                    color: context.textTertiaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                if (stats.typeSeconds.isEmpty)
                  Text(
                    'No practice data for this period.',
                    style: TextStyle(
                      fontSize: 14,
                      color: context.textSecondaryColor,
                    ),
                  )
                else
                  ...stats.typeSeconds.entries.map((entry) {
                    final type = entry.key;
                    final sec = entry.value;
                    final factor = stats.totalSeconds > 0
                        ? (sec / stats.totalSeconds).clamp(0.0, 1.0)
                        : 0.0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                type.displayName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: context.textPrimaryColor,
                                ),
                              ),
                              Text(
                                _formatTotalTime(sec),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: context.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: factor,
                              minHeight: 5,
                              backgroundColor: context.surfaceSubtleColor,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                context.accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          );

          if (isTablet) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              child: Column(
                children: [
                  periodSelector,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            metricsGrid,
                            const SizedBox(height: 16),
                            ActivityChart(
                              dailyMinutes: stats.dailyMinutes,
                              period: _selectedPeriod,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 4,
                        child: Column(
                          children: [
                            streaksCard,
                            const SizedBox(height: 16),
                            typeBreakdown,
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          return ContentContainer(
            child: ListView(
              children: [
                periodSelector,
                metricsGrid,
                const SizedBox(height: 16),
                streaksCard,
                const SizedBox(height: 16),
                ActivityChart(
                  dailyMinutes: stats.dailyMinutes,
                  period: _selectedPeriod,
                ),
                const SizedBox(height: 16),
                typeBreakdown,
                const SizedBox(height: 36),
              ],
            ),
          );
        },
      ),
    );
  }
}
