import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/achievement.dart';
import '../../../data/repositories/achievement_repository.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/responsive/responsive_layout.dart';

class AchievementsScreen extends StatelessWidget {
  final AchievementRepository achievementRepo;
  final SessionRepository sessionRepo;

  const AchievementsScreen({
    super.key,
    required this.achievementRepo,
    required this.sessionRepo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Milestones')),
      body: StreamBuilder<List<Achievement>>(
        stream: achievementRepo.watchAllAchievements(sessionRepo.watchAllSessions()),
        builder: (context, snapshot) {
          final achievements = snapshot.data ?? Achievement.definitions;
          final unlockedCount = achievements.where((a) => a.isUnlocked).length;

          return ContentContainer(
            child: ListView(
              children: [
                // Top Progress Card
                AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.accentColor.withValues(alpha: 0.15),
                        ),
                        child: Icon(
                          Icons.eco_rounded,
                          size: 28,
                          color: context.accentColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$unlockedCount of ${achievements.length} Milestones',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: context.textPrimaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Quiet markers of your ongoing practice.',
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
                ),

                const SizedBox(height: 20),

                ...achievements.map((ach) => _buildAchievementItem(context, ach)),

                const SizedBox(height: 36),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAchievementItem(BuildContext context, Achievement ach) {
    final isUnlocked = ach.isUnlocked;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: AppCard(
        padding: const EdgeInsets.all(18),
        color: isUnlocked ? context.surfaceColor : context.surfaceSubtleColor.withValues(alpha: 0.5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isUnlocked
                    ? context.accentColor.withValues(alpha: 0.15)
                    : context.borderColor,
              ),
              child: Icon(
                _getCategoryIcon(ach.category),
                size: 22,
                color: isUnlocked
                    ? context.accentColor
                    : context.textTertiaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ach.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isUnlocked
                              ? context.textPrimaryColor
                              : context.textSecondaryColor,
                        ),
                      ),
                      if (isUnlocked && ach.unlockedAt != null)
                        Text(
                          DateFormat('MMM d').format(ach.unlockedAt!),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: context.accentColor,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ach.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.textSecondaryColor,
                      height: 1.35,
                    ),
                  ),
                  if (!isUnlocked) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: ach.progress,
                        minHeight: 4,
                        backgroundColor: context.borderColor,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          context.accentColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'milestone':
        return Icons.verified_rounded;
      case 'time':
        return Icons.hourglass_top_rounded;
      case 'consistency':
        return Icons.calendar_today_rounded;
      case 'exploration':
        return Icons.explore_rounded;
      default:
        return Icons.eco_rounded;
    }
  }
}
