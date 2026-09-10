import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/meditation_type.dart';
import '../../../data/models/practice.dart';
import '../../../core/audio/audio_constants.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_sheet.dart';

class QuickStartSheet extends StatefulWidget {
  final AppAudioService audioService;
  final ValueChanged<Practice> onStart;

  const QuickStartSheet({
    super.key,
    required this.audioService,
    required this.onStart,
  });

  static void show({
    required BuildContext context,
    required AppAudioService audioService,
    required ValueChanged<Practice> onStart,
  }) {
    AppSheet.show(
      context: context,
      title: 'Quick Meditation',
      child: QuickStartSheet(
        audioService: audioService,
        onStart: onStart,
      ),
    );
  }

  @override
  State<QuickStartSheet> createState() => _QuickStartSheetState();
}

class _QuickStartSheetState extends State<QuickStartSheet> {
  int _minutes = 10;
  String _bgSound = 'none';
  String _bellSound = 'bell_singing_bowl';
  MeditationType _type = MeditationType.silentTimer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Duration Selector
          Text(
            'Duration: $_minutes minutes',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: context.textPrimaryColor,
            ),
          ),
          Slider(
            value: _minutes.toDouble(),
            min: 1,
            max: 60,
            divisions: 59,
            onChanged: (v) => setState(() => _minutes = v.toInt()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [5, 10, 15, 20, 30].map((m) {
              final isSel = _minutes == m;
              return ChoiceChip(
                label: Text('$m min'),
                selected: isSel,
                onSelected: (s) => setState(() => _minutes = m),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Meditation Type Dropdown
          Text(
            'Type',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: context.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonHideUnderline(
            child: DropdownButton<MeditationType>(
              value: _type,
              isExpanded: true,
              items: MeditationType.values.map((t) {
                return DropdownMenuItem(
                  value: t,
                  child: Text(t.displayName),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _type = v);
              },
            ),
          ),

          const SizedBox(height: 16),

          // Audio selections
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Background Sound',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.textSecondaryColor,
                      ),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _bgSound,
                        isExpanded: true,
                        items: AudioConstants.allBackgroundSounds.map((s) {
                          return DropdownMenuItem(
                            value: s.id,
                            child: Text(
                              s.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _bgSound = v);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ending Bell',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.textSecondaryColor,
                      ),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _bellSound,
                        isExpanded: true,
                        items: AudioConstants.allBells.map((s) {
                          return DropdownMenuItem(
                            value: s.id,
                            child: Text(
                              s.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _bellSound = v);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          AppButton(
            label: 'Start Meditation',
            icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
            fullWidth: true,
            onPressed: () {
              final now = DateTime.now();
              final practice = Practice(
                id: const Uuid().v4(),
                name: '${_type.displayName} ($minutes min)',
                description: 'Quick unpreset meditation session.',
                type: _type,
                durationSeconds: _minutes * 60,
                preparationSeconds: 5,
                backgroundSound: _bgSound,
                endingSound: _bellSound,
                createdAt: now,
                updatedAt: now,
              );
              Navigator.of(context).pop();
              widget.onStart(practice);
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  int get minutes => _minutes;
}
