import 'package:flutter/material.dart';
import '../../../data/models/app_settings.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../core/audio/audio_constants.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_list_row.dart';
import '../../../core/widgets/app_section_header.dart';
import '../../../core/widgets/app_segmented_control.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/responsive/breakpoints.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsRepository settingsRepo;
  final NotificationService notificationService;
  final ValueChanged<ThemeMode> onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.settingsRepo,
    required this.notificationService,
    required this.onThemeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedCategory = 'Appearance';

  @override
  Widget build(BuildContext context) {
    final isTablet = Breakpoints.isTablet(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: StreamBuilder<AppSettings>(
        stream: widget.settingsRepo.watchSettings(),
        builder: (context, snapshot) {
          final settings = snapshot.data ?? const AppSettings();

          if (isTablet) {
            final categories = [
              'Appearance',
              'Meditation',
              'Audio',
              'Reminders',
              'Display',
              'Data Management',
              'About & Privacy',
            ];

            return AdaptiveTwoPane(
              primaryWidth: 320,
              primary: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Material(
                      color: isSelected
                          ? context.accentColor.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                      title: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? context.accentColor
                              : context.textPrimaryColor,
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: isSelected
                            ? context.accentColor
                            : context.textTertiaryColor,
                      ),
                      onTap: () => setState(() => _selectedCategory = cat),
                    ),
                  ),
                );
              }).toList(),
              ),
              secondary: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                child: _buildCategoryContent(context, _selectedCategory, settings),
              ),
            );
          }

          return ContentContainer(
            child: ListView(
              children: [
                _buildAppearanceSection(context, settings),
                const SizedBox(height: 24),
                _buildMeditationDefaultsSection(context, settings),
                const SizedBox(height: 24),
                _buildAudioDefaultsSection(context, settings),
                const SizedBox(height: 24),
                _buildRemindersSection(context, settings),
                const SizedBox(height: 24),
                _buildDisplaySection(context, settings),
                const SizedBox(height: 24),
                _buildDataSection(context, settings),
                const SizedBox(height: 24),
                _buildAboutSection(context),
                const SizedBox(height: 48),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryContent(
      BuildContext context, String category, AppSettings settings) {
    switch (category) {
      case 'Appearance':
        return ListView(children: [_buildAppearanceSection(context, settings)]);
      case 'Meditation':
        return ListView(children: [_buildMeditationDefaultsSection(context, settings)]);
      case 'Audio':
        return ListView(children: [_buildAudioDefaultsSection(context, settings)]);
      case 'Reminders':
        return ListView(children: [_buildRemindersSection(context, settings)]);
      case 'Display':
        return ListView(children: [_buildDisplaySection(context, settings)]);
      case 'Data Management':
        return ListView(children: [_buildDataSection(context, settings)]);
      case 'About & Privacy':
        return ListView(children: [_buildAboutSection(context)]);
      default:
        return const SizedBox();
    }
  }

  Widget _buildAppearanceSection(BuildContext context, AppSettings settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(
          title: 'Appearance',
          subtitle: 'Choose between system, light, or dark mode',
        ),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: AppSegmentedControl<ThemeMode>(
            items: const {
              ThemeMode.system: 'System',
              ThemeMode.light: 'Light',
              ThemeMode.dark: 'Dark',
            },
            selectedValue: settings.themeMode,
            onValueChanged: (mode) {
              widget.onThemeChanged(mode);
              widget.settingsRepo.saveSettings(settings.copyWith(themeMode: mode));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMeditationDefaultsSection(BuildContext context, AppSettings settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(
          title: 'Meditation Defaults',
          subtitle: 'Starting parameters for new and quick sessions',
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              AppListRow(
                title: 'Default Duration',
                subtitle: '${settings.defaultDurationSeconds ~/ 60} minutes',
                onTap: () => _pickDefaultDuration(context, settings),
              ),
              AppListRow(
                title: 'Preparation Period',
                subtitle: '${settings.defaultPreparationSeconds} seconds',
                onTap: () => _pickDefaultPrep(context, settings),
              ),
              SwitchListTile(
                title: const Text('Haptic Guidance'),
                subtitle: const Text('Gentle vibrations at transitions'),
                value: settings.defaultHaptics,
                onChanged: (val) {
                  widget.settingsRepo
                      .saveSettings(settings.copyWith(defaultHaptics: val));
                },
              ),
              SwitchListTile(
                title: const Text('Confirm End Session'),
                subtitle: const Text('Prevent accidental cancellation'),
                value: settings.confirmEndSession,
                onChanged: (val) {
                  widget.settingsRepo
                      .saveSettings(settings.copyWith(confirmEndSession: val));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAudioDefaultsSection(BuildContext context, AppSettings settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(
          title: 'Audio & Bells',
          subtitle: 'Sound volume and default bells',
        ),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ending Bell: ${AudioConstants.getSoundById(settings.defaultEndingSound).title}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: context.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Background Audio Volume (${(settings.defaultBackgroundVolume * 100).toInt()}%)',
                style: TextStyle(fontSize: 13, color: context.textSecondaryColor),
              ),
              Slider(
                value: settings.defaultBackgroundVolume,
                onChanged: (val) {
                  widget.settingsRepo.saveSettings(
                    settings.copyWith(defaultBackgroundVolume: val),
                  );
                },
              ),
              Text(
                'Bell Volume (${(settings.defaultBellVolume * 100).toInt()}%)',
                style: TextStyle(fontSize: 13, color: context.textSecondaryColor),
              ),
              Slider(
                value: settings.defaultBellVolume,
                onChanged: (val) {
                  widget.settingsRepo.saveSettings(
                    settings.copyWith(defaultBellVolume: val),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRemindersSection(BuildContext context, AppSettings settings) {
    final timeStr = TimeOfDay(
      hour: settings.reminderHour,
      minute: settings.reminderMinute,
    ).format(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(
          title: 'Daily Reminders',
          subtitle: 'Gentle notification to practice',
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Enable Reminders'),
                subtitle: Text(
                  settings.remindersEnabled
                      ? '${settings.reminderSchedule == 'weekdays' ? 'Weekdays' : 'Daily'} at $timeStr'
                      : 'Disabled',
                ),
                value: settings.remindersEnabled,
                onChanged: (val) async {
                  if (val) {
                    final granted =
                        await widget.notificationService.requestPermission();
                    if (!granted) return;
                    await widget.notificationService.scheduleDailyReminder(
                      hour: settings.reminderHour,
                      minute: settings.reminderMinute,
                      scheduleType: settings.reminderSchedule,
                    );
                  } else {
                    await widget.notificationService.cancelReminders();
                  }
                  widget.settingsRepo.saveSettings(
                    settings.copyWith(remindersEnabled: val),
                  );
                },
              ),
              if (settings.remindersEnabled) ...[
                AppListRow(
                  title: 'Reminder Time',
                  subtitle: timeStr,
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: settings.reminderHour,
                        minute: settings.reminderMinute,
                      ),
                    );
                    if (picked != null) {
                      final updated = settings.copyWith(
                        reminderHour: picked.hour,
                        reminderMinute: picked.minute,
                      );
                      await widget.settingsRepo.saveSettings(updated);
                      await widget.notificationService.scheduleDailyReminder(
                        hour: picked.hour,
                        minute: picked.minute,
                        scheduleType: updated.reminderSchedule,
                      );
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDisplaySection(BuildContext context, AppSettings settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(
          title: 'Display Behavior',
          subtitle: 'Screen control during sessions',
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Keep Screen Awake'),
                subtitle: const Text('Default preference for timer sessions'),
                value: settings.keepScreenAwake,
                onChanged: (val) {
                  widget.settingsRepo.saveSettings(
                    settings.copyWith(keepScreenAwake: val),
                  );
                },
              ),
              SwitchListTile(
                title: const Text('Dim Display for Sleep Mode'),
                subtitle: const Text('Use deep dark palette automatically'),
                value: settings.dimDuringMeditation,
                onChanged: (val) {
                  widget.settingsRepo.saveSettings(
                    settings.copyWith(dimDuringMeditation: val),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDataSection(BuildContext context, AppSettings settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(
          title: 'Data & Backup',
          subtitle: 'Local export, import, and reset options',
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              AppListRow(
                title: 'Export Backup',
                subtitle: 'Export practices, history, and notes to JSON',
                onTap: () => _exportData(context),
              ),
              AppListRow(
                title: 'Import Backup',
                subtitle: 'Restore or merge data from a backup archive',
                onTap: () => _importDataDialog(context),
              ),
              AppListRow(
                title: 'Delete Meditation History',
                subtitle: 'Clear all recorded sessions and notes',
                titleColor: AppColors.subtleDestructive,
                onTap: () => _confirmDeleteHistory(context),
              ),
              AppListRow(
                title: 'Reset All Data',
                subtitle: 'Delete all custom practices, sessions, and milestones',
                titleColor: AppColors.subtleDestructive,
                showDivider: false,
                onTap: () => _confirmResetAllData(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(
          title: 'About & Privacy',
          subtitle: '100% offline, local-first meditation instrument',
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stillness',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Version 1.0.0 · Local-First Edition',
                style: TextStyle(
                  fontSize: 13,
                  color: context.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your meditation data stays strictly on this device. The app requires no account, contains no trackers, and operates fully offline.',
                style: TextStyle(
                  fontSize: 14,
                  color: context.textSecondaryColor,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => showLicensePage(
                  context: context,
                  applicationName: 'Stillness',
                  applicationVersion: '1.0.0',
                ),
                child: const Text('Open Source Licenses'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _pickDefaultDuration(BuildContext context, AppSettings settings) {
    AppSheet.show(
      context: context,
      title: 'Default Duration',
      child: ListView(
        shrinkWrap: true,
        children: [5, 10, 15, 20, 30, 45, 60].map((m) {
          final isSel = settings.defaultDurationSeconds == (m * 60);
          return ListTile(
            title: Text('$m minutes'),
            trailing: isSel ? Icon(Icons.check, color: context.accentColor) : null,
            onTap: () {
              widget.settingsRepo.saveSettings(
                settings.copyWith(defaultDurationSeconds: m * 60),
              );
              Navigator.of(context).pop();
            },
          );
        }).toList(),
      ),
    );
  }

  void _pickDefaultPrep(BuildContext context, AppSettings settings) {
    AppSheet.show(
      context: context,
      title: 'Preparation Countdown',
      child: ListView(
        shrinkWrap: true,
        children: [0, 5, 10, 15, 30, 60].map((s) {
          final isSel = settings.defaultPreparationSeconds == s;
          return ListTile(
            title: Text(s == 0 ? 'Off (0 seconds)' : '$s seconds'),
            trailing: isSel ? Icon(Icons.check, color: context.accentColor) : null,
            onTap: () {
              widget.settingsRepo.saveSettings(
                settings.copyWith(defaultPreparationSeconds: s),
              );
              Navigator.of(context).pop();
            },
          );
        }).toList(),
      ),
    );
  }

  void _exportData(BuildContext context) async {
    final export = await widget.settingsRepo.exportAllData();
    final jsonStr = export.toJsonString();

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Export Archive'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Backup contains ${export.practices.length} practices and ${export.sessions.length} recorded sessions.',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ctx.surfaceSubtleColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    jsonStr,
                    style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                    maxLines: 8,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  void _importDataDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import Backup Archive'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Paste a valid backup JSON string below to restore practices and history.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Paste JSON here...',
                filled: true,
                fillColor: ctx.surfaceSubtleColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          AppButton(
            label: 'Restore',
            onPressed: () async {
              try {
                final jsonStr = controller.text.trim();
                await widget.settingsRepo.importData(jsonStr, overwrite: false);
                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Backup imported successfully.')),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Import failed: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _confirmDeleteHistory(BuildContext context) async {
    final confirmed = await AppDialog.showConfirmation(
      context,
      title: 'Delete History?',
      content: 'This will delete all past meditation sessions and reflections. Built-in and custom practices will be preserved.',
      confirmLabel: 'Delete History',
      isDestructive: true,
    );

    if (confirmed == true) {
      await widget.settingsRepo.deleteAllMeditationData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meditation history cleared.')),
        );
      }
    }
  }

  void _confirmResetAllData(BuildContext context) async {
    final confirmed = await AppDialog.showConfirmation(
      context,
      title: 'Reset All Data?',
      content: 'This will permanently delete all meditation history, custom practices, achievements, and settings, resetting the application to fresh defaults.',
      confirmLabel: 'Reset Entire App',
      isDestructive: true,
    );

    if (confirmed == true) {
      await widget.settingsRepo.resetEntireApp();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('App reset to initial defaults.')),
        );
      }
    }
  }
}
