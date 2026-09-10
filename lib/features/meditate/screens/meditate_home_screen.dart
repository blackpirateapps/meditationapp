import 'package:flutter/material.dart';
import '../../../data/models/practice.dart';
import '../../../data/repositories/practice_repository.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_section_header.dart';
import '../../../core/responsive/responsive_layout.dart';
import 'quick_start_sheet.dart';
import 'practice_browser_screen.dart';

class MeditateHomeScreen extends StatelessWidget {
  final PracticeRepository practiceRepo;
  final SessionRepository sessionRepo;
  final AppAudioService audioService;
  final ValueChanged<Practice> onStartPractice;

  const MeditateHomeScreen({
    super.key,
    required this.practiceRepo,
    required this.sessionRepo,
    required this.audioService,
    required this.onStartPractice,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getGreeting()),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.timer_outlined, size: 18),
            label: const Text('Quick'),
            onPressed: () => QuickStartSheet.show(
              context: context,
              audioService: audioService,
              onStart: onStartPractice,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.grid_view_rounded),
            tooltip: 'All Practices',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => PracticeBrowserScreen(
                    practiceRepo: practiceRepo,
                    audioService: audioService,
                    onStartPractice: onStartPractice,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Practice>>(
        stream: practiceRepo.watchAllPractices(),
        builder: (context, snapshot) {
          final allPractices = snapshot.data ?? [];
          final ranked = practiceRepo.rankPractices(allPractices);

          if (ranked.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final featured = ranked.first;
          final shortcuts = ranked.skip(1).take(4).toList();
          final recentlyUsed = allPractices
              .where((p) => p.lastUsedAt != null)
              .toList()
            ..sort((a, b) => b.lastUsedAt!.compareTo(a.lastUsedAt!));

          return ContentContainer(
            child: ListView(
              children: [
                // Top Highlight / Continue Section
                const AppSectionHeader(
                  title: 'Continue',
                  padding: EdgeInsets.only(top: 8, bottom: 12),
                ),
                _buildFeaturedCard(context, featured),

                const SizedBox(height: 28),

                // Quick Practices Grid
                AppSectionHeader(
                  title: 'Your Practices',
                  trailing: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => PracticeBrowserScreen(
                            practiceRepo: practiceRepo,
                            audioService: audioService,
                            onStartPractice: onStartPractice,
                          ),
                        ),
                      );
                    },
                    child: const Text('See all'),
                  ),
                ),
                _buildShortcutsGrid(context, shortcuts),

                // Recently Used Section
                if (recentlyUsed.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  const AppSectionHeader(
                    title: 'Recently Used',
                  ),
                  ...recentlyUsed.take(3).map((p) => _buildRecentRow(context, p)),
                ],

                const SizedBox(height: 36),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context, Practice p) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: context.accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  p.type.displayName.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                    color: context.accentColor,
                  ),
                ),
              ),
              Text(
                '${p.durationSeconds ~/ 60} min',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: context.textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            p.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.4,
              color: context.textPrimaryColor,
            ),
          ),
          if (p.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              p.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: context.textSecondaryColor,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Start Meditation',
                  icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                  onPressed: () => onStartPractice(p),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutsGrid(BuildContext context, List<Practice> list) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.45,
      ),
      itemCount: list.length,
      itemBuilder: (ctx, i) {
        final p = list[i];
        return AppCard(
          padding: const EdgeInsets.all(16),
          onTap: () => onStartPractice(p),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${p.durationSeconds ~/ 60} min',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.accentColor,
                    ),
                  ),
                  Icon(
                    Icons.play_circle_outline_rounded,
                    size: 20,
                    color: context.textTertiaryColor,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    p.type.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentRow(BuildContext context, Practice p) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        onTap: () => onStartPractice(p),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: context.surfaceSubtleColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.self_improvement_rounded,
                  size: 20,
                  color: context.accentColor,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  Text(
                    '${p.durationSeconds ~/ 60} min · ${p.type.displayName}',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.play_arrow_rounded,
              size: 24,
              color: context.accentColor,
            ),
          ],
        ),
      ),
    );
  }
}
