import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/meditation_session.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_section_header.dart';
import '../../../core/responsive/responsive_layout.dart';

class SessionDetailScreen extends StatelessWidget {
  final MeditationSession session;
  final SessionRepository sessionRepo;
  final VoidCallback? onDeleted;

  const SessionDetailScreen({
    super.key,
    required this.session,
    required this.sessionRepo,
    this.onDeleted,
  });

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m > 0 && s == 0) return '$m min';
    if (m > 0) return '$m min $s sec';
    return '$s sec';
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMMM d, y · h:mm a');
    final formattedDate = dateFormat.format(session.startedAt);
    final snapshot = session.snapshot;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Delete Session',
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: ContentContainer(
        child: ListView(
          children: [
            // Top Summary Card
            AppCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        snapshot.meditationType.displayName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: context.accentColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: session.isCompleted
                              ? Colors.green.withValues(alpha: 0.12)
                              : Colors.orange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          session.isCompleted ? 'Completed' : 'Partial',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: session.isCompleted
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    snapshot.practiceName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ACTUAL TIME',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: context.textTertiaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDuration(session.actualDurationSeconds),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: context.textPrimaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PLANNED TIME',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: context.textTertiaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDuration(session.plannedDurationSeconds),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: context.textPrimaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Mood and Journal Reflection
            if (session.mood != null || (session.note != null && session.note!.isNotEmpty)) ...[
              const SizedBox(height: 20),
              const AppSectionHeader(title: 'Reflection & Notes'),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (session.mood != null) ...[
                      Row(
                        children: [
                          Text(
                            _getMoodEmoji(session.mood!),
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getMoodLabel(session.mood!),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: context.textPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (session.note != null && session.note!.isNotEmpty) ...[
                      if (session.mood != null) const SizedBox(height: 12),
                      Text(
                        session.note!,
                        style: TextStyle(
                          fontSize: 15,
                          color: context.textPrimaryColor,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Historical Snapshot Settings (Section 38: Integrity Guarantee)
            const AppSectionHeader(
              title: 'Historical Configuration',
              subtitle: 'Settings snapshot at the time of meditation',
            ),
            AppCard(
              child: Column(
                children: [
                  _snapshotRow('Background Audio', snapshot.backgroundSound, context),
                  _snapshotRow('Ending Bell', snapshot.endingSound, context),
                  _snapshotRow('Preparation', '${snapshot.preparationSeconds}s', context),
                  _snapshotRow(
                    'Interval Bell',
                    snapshot.intervalBellEnabled
                        ? '${snapshot.intervalBellIntervalSeconds ~/ 60}m'
                        : 'Disabled',
                    context,
                  ),
                  _snapshotRow(
                    'Screen Behavior',
                    snapshot.screenBehavior == 'keepAwake'
                        ? 'Keep Screen Awake'
                        : 'Allow Screen Sleep',
                    context,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _snapshotRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: context.textSecondaryColor)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: context.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  String _getMoodEmoji(String mood) {
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

  String _getMoodLabel(String mood) {
    switch (mood) {
      case 'peaceful':
        return 'Felt Peaceful';
      case 'content':
        return 'Felt Content';
      case 'neutral':
        return 'Felt Neutral';
      case 'restless':
        return 'Felt Restless';
      case 'difficult':
        return 'Felt Challenging';
      default:
        return mood;
    }
  }

  void _confirmDelete(BuildContext context) async {
    final confirmed = await AppDialog.showConfirmation(
      context,
      title: 'Delete Session?',
      content: 'This session record and note will be permanently removed from history.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true) {
      await sessionRepo.deleteSession(session.id);
      if (context.mounted) {
        if (onDeleted != null) {
          onDeleted!();
        } else {
          Navigator.of(context).pop();
        }
      }
    }
  }
}
