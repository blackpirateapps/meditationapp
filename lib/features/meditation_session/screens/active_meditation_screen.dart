import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/session_controller.dart';
import '../widgets/visual_guidance_view.dart';
import '../widgets/meditation_controls_overlay.dart';
import 'completion_journal_screen.dart';
import '../../../data/models/meditation_session.dart';
import '../../../data/models/meditation_type.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_dialog.dart';

class ActiveMeditationScreen extends StatefulWidget {
  final SessionController controller;

  const ActiveMeditationScreen({
    super.key,
    required this.controller,
  });

  @override
  State<ActiveMeditationScreen> createState() => _ActiveMeditationScreenState();
}

class _ActiveMeditationScreenState extends State<ActiveMeditationScreen> {
  Timer? _overlayHideTimer;
  bool _hasNavigatedToCompletion = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerUpdate);
    widget.controller.start();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    _overlayHideTimer?.cancel();
    widget.controller.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (widget.controller.state == SessionState.completed &&
        !_hasNavigatedToCompletion) {
      _hasNavigatedToCompletion = true;
      _navigateToCompletion();
    }
  }

  void _navigateToCompletion({SessionStatus? status}) async {
    final controller = widget.controller;
    final initialSession = await controller.finalizeSession(
      forcedStatus: status,
    );

    if (!mounted) return;

    final sessionRepo = controller.sessionRepo;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (ctx, anim, secAnim) => CompletionJournalScreen(
          initialSession: initialSession,
          onSave: (mood, note) async {
            final updated = initialSession.copyWith(
              mood: mood,
              note: note,
            );
            await sessionRepo.saveSession(updated);
          },
        ),
        transitionsBuilder: (ctx, anim, secAnim, child) {
          return FadeTransition(opacity: anim, child: child);
        },
      ),
    );
  }

  void _toggleControls() {
    widget.controller.toggleControls();
    _resetOverlayTimer();
  }

  void _resetOverlayTimer() {
    _overlayHideTimer?.cancel();
    if (widget.controller.controlsVisible &&
        widget.controller.state == SessionState.active) {
      _overlayHideTimer = Timer(const Duration(seconds: 5), () {
        if (mounted && widget.controller.controlsVisible) {
          widget.controller.toggleControls();
        }
      });
    }
  }

  String _formatTime(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.controller,
      child: Consumer<SessionController>(
        builder: (context, controller, child) {
          final isSleep = controller.practice.type == MeditationType.sleep;
          final isDimmed = controller.isDimmed;

          Color bgColor;
          Color textColor;
          if (isDimmed || isSleep) {
            bgColor = AppColors.sleepBackground;
            textColor = AppColors.sleepTextPrimary;
          } else {
            bgColor = context.surfaceColor;
            textColor = context.textPrimaryColor;
          }

          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;
              if (!controller.controlsVisible) {
                _toggleControls();
                return;
              }
              final confirmed = await AppDialog.showConfirmation(
                context,
                title: 'End meditation?',
                content: 'Your current progress will be recorded.',
                confirmLabel: 'End session',
                cancelLabel: 'Continue meditating',
                isDestructive: true,
              );
              if (confirmed == true) {
                _navigateToCompletion(status: SessionStatus.partial);
              }
            },
            child: Scaffold(
              backgroundColor: bgColor,
              body: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggleControls,
                child: Stack(
                  children: [
                    // Main Content
                    SafeArea(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                              vertical: 32.0,
                            ),
                            child: controller.state == SessionState.preparing
                                ? _buildPrepView(controller, textColor)
                                : _buildActiveView(controller, textColor),
                          ),
                        ),
                      ),
                    ),

                    // Controls Overlay
                    if (controller.controlsVisible)
                      MeditationControlsOverlay(
                        controller: controller,
                        onEndConfirmed: () => _navigateToCompletion(
                          status: SessionStatus.partial,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPrepView(SessionController controller, Color textColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Get comfortable',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.3,
            color: textColor.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 36),
        Text(
          'Starting in',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
            color: textColor.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${controller.prepSecondsRemaining}',
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w200,
            letterSpacing: -1.0,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveView(SessionController controller, Color textColor) {
    return Column(
      children: [
        // Top Remaining / Elapsed Time
        Text(
          _formatTime(controller.remainingSeconds),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w300,
            letterSpacing: -0.5,
            color: textColor.withValues(alpha: 0.85),
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const Spacer(),

        // Central Guidance Visualization
        VisualGuidanceView(controller: controller),

        const Spacer(),

        // Subtle Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: SizedBox(
            height: 2.5,
            width: 140,
            child: LinearProgressIndicator(
              value: controller.progress,
              backgroundColor: textColor.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                textColor.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
