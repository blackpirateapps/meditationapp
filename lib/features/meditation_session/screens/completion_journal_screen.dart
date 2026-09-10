import 'package:flutter/material.dart';
import '../../../data/models/meditation_session.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/haptics/haptic_service.dart';

class CompletionJournalScreen extends StatefulWidget {
  final MeditationSession initialSession;
  final Future<void> Function(String? mood, String? note) onSave;

  const CompletionJournalScreen({
    super.key,
    required this.initialSession,
    required this.onSave,
  });

  @override
  State<CompletionJournalScreen> createState() =>
      _CompletionJournalScreenState();
}

class _CompletionJournalScreenState extends State<CompletionJournalScreen> {
  final TextEditingController _noteController = TextEditingController();
  String? _selectedMood;
  bool _isSaving = false;

  final List<Map<String, String>> _moods = const [
    {'id': 'peaceful', 'emoji': '😌', 'label': 'Peaceful'},
    {'id': 'content', 'emoji': '🙂', 'label': 'Content'},
    {'id': 'neutral', 'emoji': '😐', 'label': 'Neutral'},
    {'id': 'restless', 'emoji': '😕', 'label': 'Restless'},
    {'id': 'difficult', 'emoji': '😣', 'label': 'Difficult'},
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    final note = _noteController.text.trim();
    await widget.onSave(
      _selectedMood,
      note.isNotEmpty ? note : null,
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    if (minutes > 0 && seconds == 0) {
      return '$minutes minute${minutes == 1 ? '' : 's'}';
    } else if (minutes > 0) {
      return '$minutes min $seconds sec';
    } else {
      return '$seconds seconds';
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.initialSession;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _handleSave, // Dismissing immediately saves session
        ),
      ),
      body: SafeArea(
        child: ContentContainer(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.sereneGreen.withValues(alpha: 0.15),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_rounded,
                        size: 32,
                        color: AppColors.sereneGreen,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'Session Complete',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                      color: context.textPrimaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    '${_formatDuration(session.actualDurationSeconds)} · ${session.snapshot.practiceName}',
                    style: TextStyle(
                      fontSize: 15,
                      color: context.textSecondaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'How do you feel?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimaryColor,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _moods.map((m) {
                    final isSelected = _selectedMood == m['id'];
                    return GestureDetector(
                      onTap: () {
                        HapticService.selection();
                        setState(() {
                          _selectedMood = isSelected ? null : m['id'];
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? context.accentColor.withValues(alpha: 0.15)
                              : context.surfaceSubtleColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? context.accentColor
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              m['emoji']!,
                              style: const TextStyle(fontSize: 28),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              m['label']!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? context.accentColor
                                    : context.textTertiaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 36),
                Text(
                  'Reflections (Optional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimaryColor,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteController,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Notice thoughts, sensations, or gentle realizations...',
                    hintStyle: TextStyle(
                      color: context.textTertiaryColor,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: context.surfaceSubtleColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  style: TextStyle(
                    fontSize: 15,
                    color: context.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 40),
                AppButton(
                  label: 'Done',
                  isLoading: _isSaving,
                  fullWidth: true,
                  onPressed: _handleSave,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
