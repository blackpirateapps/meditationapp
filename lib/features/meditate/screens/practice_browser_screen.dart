import 'package:flutter/material.dart';
import '../../../data/models/practice.dart';
import '../../../data/repositories/practice_repository.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_list_row.dart';
import '../../../core/widgets/app_section_header.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../practices/screens/practice_editor_screen.dart';

class PracticeBrowserScreen extends StatefulWidget {
  final PracticeRepository practiceRepo;
  final AppAudioService audioService;
  final ValueChanged<Practice> onStartPractice;

  const PracticeBrowserScreen({
    super.key,
    required this.practiceRepo,
    required this.audioService,
    required this.onStartPractice,
  });

  @override
  State<PracticeBrowserScreen> createState() => _PracticeBrowserScreenState();
}

class _PracticeBrowserScreenState extends State<PracticeBrowserScreen> {
  Practice? _selectedPractice;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Practice>>(
      stream: widget.practiceRepo.watchAllPractices(),
      builder: (context, snapshot) {
        final practices = snapshot.data ?? [];
        final builtIns = practices.where((p) => p.isBuiltIn).toList();
        final custom = practices.where((p) => !p.isBuiltIn).toList();

        // Default selection for tablet
        if (_selectedPractice == null && practices.isNotEmpty) {
          _selectedPractice = practices.first;
        } else if (_selectedPractice != null) {
          // Keep updated
          final idx = practices.indexWhere((p) => p.id == _selectedPractice!.id);
          if (idx != -1) _selectedPractice = practices[idx];
        }

        final isTablet = Breakpoints.isTablet(context);

        final listWidget = ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // Custom Practices
            AppSectionHeader(
              title: 'Your Practices',
              subtitle: custom.isEmpty ? 'No custom practices yet' : null,
              trailing: TextButton.icon(
                onPressed: () => _openEditor(null),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Create'),
              ),
            ),
            if (custom.isNotEmpty)
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: custom.map((p) => _buildPracticeRow(p)).toList(),
                ),
              ),

            const SizedBox(height: 24),

            // Built-In Practices
            const AppSectionHeader(
              title: 'Built-in Practices',
              subtitle: 'Core collection of curated meditations',
            ),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: builtIns.map((p) => _buildPracticeRow(p)).toList(),
              ),
            ),
            const SizedBox(height: 32),
          ],
        );

        if (isTablet) {
          return Scaffold(
            appBar: AppBar(title: const Text('Practices')),
            body: AdaptiveTwoPane(
              primaryWidth: 380,
              primary: listWidget,
              secondary: _selectedPractice != null
                  ? _buildDetailPane(_selectedPractice!)
                  : const AppEmptyState(
                      icon: Icons.self_improvement_rounded,
                      title: 'Select a Practice',
                      message: 'Choose a practice from the left to view details.',
                    ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Practices'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded),
                onPressed: () => _openEditor(null),
                tooltip: 'Create Practice',
              ),
            ],
          ),
          body: listWidget,
        );
      },
    );
  }

  Widget _buildPracticeRow(Practice p) {
    final isSelected = _selectedPractice?.id == p.id;
    final isTablet = Breakpoints.isTablet(context);

    return Container(
      color: isTablet && isSelected
          ? context.accentColor.withValues(alpha: 0.1)
          : Colors.transparent,
      child: AppListRow(
        leading: Icon(
          p.isPinned
              ? Icons.push_pin_rounded
              : (p.isFavorite
                  ? Icons.favorite_rounded
                  : Icons.self_improvement_rounded),
          size: 22,
          color: p.isPinned || p.isFavorite
              ? context.accentColor
              : context.textTertiaryColor,
        ),
        title: p.name,
        subtitle: '${p.durationSeconds ~/ 60} min · ${p.type.displayName}',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                p.isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                size: 20,
                color: p.isFavorite ? Colors.redAccent : context.textTertiaryColor,
              ),
              onPressed: () => widget.practiceRepo.toggleFavorite(p.id),
            ),
            IconButton(
              icon: const Icon(Icons.play_circle_fill_rounded, size: 28),
              color: context.accentColor,
              onPressed: () => widget.onStartPractice(p),
            ),
          ],
        ),
        onTap: () {
          setState(() => _selectedPractice = p);
          if (!isTablet) {
            _showPracticeSheet(p);
          }
        },
      ),
    );
  }

  Widget _buildDetailPane(Practice p) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  p.name,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimaryColor,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  p.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  color: p.isPinned ? context.accentColor : context.textTertiaryColor,
                ),
                onPressed: () => widget.practiceRepo.togglePin(p.id),
              ),
              IconButton(
                icon: Icon(
                  p.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: p.isFavorite ? Colors.redAccent : context.textTertiaryColor,
                ),
                onPressed: () => widget.practiceRepo.toggleFavorite(p.id),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${p.durationSeconds ~/ 60} minutes · ${p.type.displayName}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: context.accentColor,
            ),
          ),
          if (p.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              p.description,
              style: TextStyle(
                fontSize: 15,
                color: context.textSecondaryColor,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 32),
          AppCard(
            child: Column(
              children: [
                _detailRow('Preparation', '${p.preparationSeconds}s'),
                _detailRow('Ending Sound', p.endingSound),
                _detailRow('Background Audio', p.backgroundSound),
                _detailRow('Interval Bell',
                    p.intervalBellEnabled ? '${p.intervalBellIntervalSeconds ~/ 60}m' : 'Off'),
                _detailRow('Times Practiced', '${p.useCount} sessions'),
              ],
            ),
          ),
          const Spacer(),
          Row(
            children: [
              AppButton(
                label: p.isBuiltIn ? 'Customize' : 'Edit',
                variant: AppButtonVariant.secondary,
                icon: const Icon(Icons.edit_rounded, size: 18),
                onPressed: () => _openEditor(p),
              ),
              const SizedBox(width: 12),
              if (!p.isBuiltIn) ...[
                AppButton(
                  label: 'Delete',
                  variant: AppButtonVariant.destructive,
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  onPressed: () => _confirmDelete(p),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: AppButton(
                  label: 'Start Meditation',
                  icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                  onPressed: () => widget.onStartPractice(p),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: context.textSecondaryColor),
          ),
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

  void _showPracticeSheet(Practice p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  p.name,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${p.durationSeconds ~/ 60} minutes · ${p.type.displayName}',
                  style: TextStyle(
                    fontSize: 14,
                    color: context.accentColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (p.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    p.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.textSecondaryColor,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: p.isBuiltIn ? 'Customize' : 'Edit',
                        variant: AppButtonVariant.secondary,
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _openEditor(p);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: 'Start',
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          widget.onStartPractice(p);
                        },
                      ),
                    ),
                  ],
                ),
                if (!p.isBuiltIn) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _confirmDelete(p);
                    },
                    child: const Text(
                      'Delete Practice',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _openEditor(Practice? p) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => PracticeEditorScreen(
          initialPractice: p,
          practiceRepo: widget.practiceRepo,
          audioService: widget.audioService,
        ),
      ),
    );
  }

  void _confirmDelete(Practice p) async {
    final confirmed = await AppDialog.showConfirmation(
      context,
      title: 'Delete Practice?',
      content: 'Are you sure you want to delete "${p.name}"? Past meditation sessions will remain in your history.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true) {
      await widget.practiceRepo.deletePractice(p.id);
    }
  }
}
