import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/meditation_type.dart';
import '../../../data/models/practice.dart';
import '../../../data/models/breathing_config.dart';
import '../../../data/models/body_scan_config.dart';
import '../../../data/models/mantra_config.dart';
import '../../../data/models/walking_config.dart';
import '../../../data/repositories/practice_repository.dart';
import '../../../core/audio/audio_constants.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_list_row.dart';
import '../../../core/widgets/app_section_header.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/responsive/responsive_layout.dart';

class PracticeEditorScreen extends StatefulWidget {
  final Practice? initialPractice;
  final PracticeRepository practiceRepo;
  final AppAudioService audioService;

  const PracticeEditorScreen({
    super.key,
    this.initialPractice,
    required this.practiceRepo,
    required this.audioService,
  });

  @override
  State<PracticeEditorScreen> createState() => _PracticeEditorScreenState();
}

class _PracticeEditorScreenState extends State<PracticeEditorScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _mantraController;

  late MeditationType _type;
  late int _durationMinutes;
  late int _prepSeconds;
  late bool _visualGuidance;
  late bool _hapticGuidance;
  late bool _intervalBellEnabled;
  late int _intervalBellMinutes;
  late String _intervalBellSound;
  late double _intervalBellVolume;
  late String _startSound;
  late bool _startSoundEnabled;
  late String _endingSound;
  late bool _endingSoundEnabled;
  late String _backgroundSound;
  late double _backgroundSoundVolume;
  late int _fadeInSeconds;
  late int _fadeOutSeconds;
  late String _screenBehavior;

  // Type configs
  late BreathingConfig _breathingConfig;
  late BodyScanConfig _bodyScanConfig;
  late MantraConfig _mantraConfig;
  late WalkingConfig _walkingConfig;

  bool _isAdvancedExpanded = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final p = widget.initialPractice;

    _nameController = TextEditingController(text: p?.name ?? 'My Practice');
    _descController = TextEditingController(text: p?.description ?? '');
    _mantraController = TextEditingController(
      text: p?.mantraConfig?.mantraText ?? 'Peace begins with me',
    );

    _type = p?.type ?? MeditationType.silentTimer;
    _durationMinutes = p != null ? (p.durationSeconds ~/ 60) : 10;
    if (_durationMinutes == 0) _durationMinutes = 1;
    _prepSeconds = p?.preparationSeconds ?? 10;
    _visualGuidance = p?.visualGuidance ?? true;
    _hapticGuidance = p?.hapticGuidance ?? true;
    _intervalBellEnabled = p?.intervalBellEnabled ?? false;
    _intervalBellMinutes =
        p != null ? (p.intervalBellIntervalSeconds ~/ 60) : 5;
    if (_intervalBellMinutes == 0) _intervalBellMinutes = 1;
    _intervalBellSound = p?.intervalBellSound ?? 'bell_chime';
    _intervalBellVolume = p?.intervalBellVolume ?? 0.8;
    _startSound = p?.startSound ?? 'bell_singing_bowl';
    _startSoundEnabled = p?.startSoundEnabled ?? true;
    _endingSound = p?.endingSound ?? 'bell_tingsha';
    _endingSoundEnabled = p?.endingSoundEnabled ?? true;
    _backgroundSound = p?.backgroundSound ?? 'none';
    _backgroundSoundVolume = p?.backgroundSoundVolume ?? 0.5;
    _fadeInSeconds = p?.fadeInSeconds ?? 3;
    _fadeOutSeconds = p?.fadeOutSeconds ?? 5;
    _screenBehavior = p?.screenBehavior ?? 'keepAwake';

    _breathingConfig = p?.breathingConfig ?? BreathingConfig.box;
    _bodyScanConfig = p?.bodyScanConfig ?? const BodyScanConfig();
    _mantraConfig = p?.mantraConfig ?? const MantraConfig();
    _walkingConfig = p?.walkingConfig ?? const WalkingConfig();

    _nameController.addListener(() => _hasChanges = true);
    _descController.addListener(() => _hasChanges = true);
    _mantraController.addListener(() => _hasChanges = true);
  }

  @override
  void dispose() {
    widget.audioService.stopPreview();
    _nameController.dispose();
    _descController.dispose();
    _mantraController.dispose();
    super.dispose();
  }

  Future<void> _savePractice() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final now = DateTime.now();
    final isCustomizingBuiltIn = widget.initialPractice?.isBuiltIn ?? false;
    final practiceId = isCustomizingBuiltIn || widget.initialPractice == null
        ? const Uuid().v4()
        : widget.initialPractice!.id;

    final practice = Practice(
      id: practiceId,
      name: isCustomizingBuiltIn ? '$name (Custom)' : name,
      description: _descController.text.trim(),
      type: _type,
      durationSeconds: _durationMinutes * 60,
      preparationSeconds: _prepSeconds,
      visualGuidance: _visualGuidance,
      hapticGuidance: _hapticGuidance,
      intervalBellEnabled: _intervalBellEnabled,
      intervalBellIntervalSeconds: _intervalBellMinutes * 60,
      intervalBellSound: _intervalBellSound,
      intervalBellVolume: _intervalBellVolume,
      startSound: _startSound,
      startSoundEnabled: _startSoundEnabled,
      endingSound: _endingSound,
      endingSoundEnabled: _endingSoundEnabled,
      backgroundSound: _backgroundSound,
      backgroundSoundVolume: _backgroundSoundVolume,
      fadeInSeconds: _fadeInSeconds,
      fadeOutSeconds: _fadeOutSeconds,
      screenBehavior: _screenBehavior,
      breathingConfig:
          _type == MeditationType.breathing ? _breathingConfig : null,
      bodyScanConfig: _type == MeditationType.bodyScan ? _bodyScanConfig : null,
      mantraConfig: _type == MeditationType.mantra
          ? _mantraConfig.copyWith(mantraText: _mantraController.text.trim())
          : null,
      walkingConfig: _type == MeditationType.walking ? _walkingConfig : null,
      createdAt: widget.initialPractice?.createdAt ?? now,
      updatedAt: now,
      isBuiltIn: false, // Customized copies or user creations are always custom
      isFavorite: widget.initialPractice?.isFavorite ?? false,
      isPinned: widget.initialPractice?.isPinned ?? false,
      useCount: widget.initialPractice?.useCount ?? 0,
      lastUsedAt: widget.initialPractice?.lastUsedAt,
    );

    await widget.practiceRepo.savePractice(practice);
    if (mounted) {
      Navigator.of(context).pop(practice);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialPractice != null;
    final isBuiltIn = widget.initialPractice?.isBuiltIn ?? false;

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final discard = await AppDialog.showConfirmation(
          context,
          title: 'Discard changes?',
          content: 'You have unsaved modifications to this practice.',
          confirmLabel: 'Discard',
          cancelLabel: 'Keep editing',
          isDestructive: true,
        );
        if (discard == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing
              ? (isBuiltIn ? 'Customize Practice' : 'Edit Practice')
              : 'New Practice'),
          actions: [
            TextButton(
              onPressed: _savePractice,
              child: Text(
                'Save',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.accentColor,
                ),
              ),
            ),
          ],
        ),
        body: ContentContainer(
          child: ListView(
            children: [
              // Basic Section
              const AppSectionHeader(
                title: 'Basic Information',
                padding: EdgeInsets.only(bottom: 12),
              ),
              AppCard(
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Practice Name',
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const Divider(height: 1),
                    TextField(
                      controller: _descController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Practice Type
              const AppSectionHeader(
                title: 'Meditation Type',
                padding: EdgeInsets.only(bottom: 12),
              ),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<MeditationType>(
                    value: _type,
                    isExpanded: true,
                    items: MeditationType.values.map((t) {
                      return DropdownMenuItem(
                        value: t,
                        child: Text(
                          t.displayName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: context.textPrimaryColor,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _type = val;
                          _hasChanges = true;
                        });
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Duration Section
              AppSectionHeader(
                title: 'Duration',
                subtitle: '$_durationMinutes minutes',
                padding: const EdgeInsets.only(bottom: 8),
              ),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Slider(
                      value: _durationMinutes.toDouble(),
                      min: 1,
                      max: 120,
                      divisions: 119,
                      onChanged: (val) {
                        setState(() {
                          _durationMinutes = val.toInt();
                          _hasChanges = true;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _quickDurationChip(5),
                        _quickDurationChip(10),
                        _quickDurationChip(15),
                        _quickDurationChip(20),
                        _quickDurationChip(30),
                        _quickDurationChip(45),
                        _quickDurationChip(60),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Type Specific Config View
              if (_type == MeditationType.breathing) _buildBreathingSection(),
              if (_type == MeditationType.mantra) _buildMantraSection(),

              const SizedBox(height: 16),

              // Sound Section
              const AppSectionHeader(
                title: 'Audio & Bells',
                padding: EdgeInsets.only(bottom: 12),
              ),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    AppListRow(
                      title: 'Background Sound',
                      subtitle: AudioConstants.getSoundById(_backgroundSound).title,
                      onTap: () => _pickSound(isBell: false),
                    ),
                    if (_backgroundSound != 'none') ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.volume_down_rounded, size: 20),
                            Expanded(
                              child: Slider(
                                value: _backgroundSoundVolume,
                                onChanged: (val) {
                                  setState(() {
                                    _backgroundSoundVolume = val;
                                    _hasChanges = true;
                                  });
                                },
                              ),
                            ),
                            const Icon(Icons.volume_up_rounded, size: 20),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                    ],
                    AppListRow(
                      title: 'Ending Bell',
                      subtitle: _endingSoundEnabled
                          ? AudioConstants.getSoundById(_endingSound).title
                          : 'Disabled',
                      onTap: () => _pickSound(isBell: true),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Advanced Configuration Expansion
              AppCard(
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => setState(() {
                        _isAdvancedExpanded = !_isAdvancedExpanded;
                      }),
                      child: Row(
                        children: [
                          Icon(
                            _isAdvancedExpanded
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                            color: context.accentColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Advanced Behavior Settings',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: context.accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_isAdvancedExpanded) ...[
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Preparation Period'),
                        subtitle: Text('$_prepSeconds seconds countdown'),
                        value: _prepSeconds > 0,
                        onChanged: (val) => setState(() {
                          _prepSeconds = val ? 10 : 0;
                          _hasChanges = true;
                        }),
                      ),
                      SwitchListTile(
                        title: const Text('Haptic Cues'),
                        subtitle: const Text('Subtle vibrations at transitions'),
                        value: _hapticGuidance,
                        onChanged: (val) => setState(() {
                          _hapticGuidance = val;
                          _hasChanges = true;
                        }),
                      ),
                      SwitchListTile(
                        title: const Text('Interval Bells'),
                        subtitle: Text(_intervalBellEnabled
                            ? 'Every $_intervalBellMinutes minutes'
                            : 'Disabled'),
                        value: _intervalBellEnabled,
                        onChanged: (val) => setState(() {
                          _intervalBellEnabled = val;
                          _hasChanges = true;
                        }),
                      ),
                      SwitchListTile(
                        title: const Text('Keep Screen Awake'),
                        subtitle: const Text('Prevent display from sleeping'),
                        value: _screenBehavior == 'keepAwake',
                        onChanged: (val) => setState(() {
                          _screenBehavior = val ? 'keepAwake' : 'allowSleep';
                          _hasChanges = true;
                        }),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickDurationChip(int minutes) {
    final isSelected = _durationMinutes == minutes;
    return GestureDetector(
      onTap: () => setState(() {
        _durationMinutes = minutes;
        _hasChanges = true;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? context.accentColor.withValues(alpha: 0.15)
              : context.surfaceSubtleColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? context.accentColor : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          '$minutes m',
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? context.accentColor : context.textSecondaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildBreathingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(
          title: 'Breathing Rhythm',
          padding: EdgeInsets.only(bottom: 12),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pattern Presets',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.textTertiaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: BreathingConfig.presets.map((preset) {
                  final isSelected = _breathingConfig.presetName == preset.presetName;
                  return ChoiceChip(
                    label: Text(preset.presetName),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _breathingConfig = preset;
                          _hasChanges = true;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(
                'Inhale: ${_breathingConfig.inhaleSeconds}s · Hold: ${_breathingConfig.inhaleHoldSeconds}s · Exhale: ${_breathingConfig.exhaleSeconds}s · Hold: ${_breathingConfig.exhaleHoldSeconds}s',
                style: TextStyle(
                  fontSize: 13,
                  color: context.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMantraSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(
          title: 'Mantra Configuration',
          padding: EdgeInsets.only(bottom: 12),
        ),
        AppCard(
          child: TextField(
            controller: _mantraController,
            decoration: const InputDecoration(
              labelText: 'Mantra Phrase',
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  void _pickSound({required bool isBell}) {
    final sounds = isBell
        ? AudioConstants.allBells
        : AudioConstants.allBackgroundSounds;

    AppSheet.show(
      context: context,
      title: isBell ? 'Choose Ending Bell' : 'Choose Background Sound',
      child: StatefulBuilder(
        builder: (ctx, setSheetState) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: sounds.length,
            itemBuilder: (ctx, i) {
              final s = sounds[i];
              final isCurrent =
                  isBell ? _endingSound == s.id : _backgroundSound == s.id;

              return ListTile(
                title: Text(s.title),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (s.id != 'none')
                      IconButton(
                        icon: const Icon(Icons.play_arrow_rounded),
                        onPressed: () {
                          widget.audioService.playPreview(s.id, isBell: isBell);
                        },
                      ),
                    if (isCurrent)
                      Icon(Icons.check_rounded, color: context.accentColor),
                  ],
                ),
                onTap: () {
                  widget.audioService.stopPreview();
                  setState(() {
                    if (isBell) {
                      _endingSound = s.id;
                      _endingSoundEnabled = s.id != 'none';
                    } else {
                      _backgroundSound = s.id;
                    }
                    _hasChanges = true;
                  });
                  Navigator.of(ctx).pop();
                },
              );
            },
          );
        },
      ),
    );
  }
}
