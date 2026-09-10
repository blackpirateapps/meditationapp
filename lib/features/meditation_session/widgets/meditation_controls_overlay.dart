import 'package:flutter/material.dart';
import '../controllers/session_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_icon_button.dart';
import '../../../core/widgets/app_sheet.dart';

class MeditationControlsOverlay extends StatelessWidget {
  final SessionController controller;
  final VoidCallback onEndConfirmed;

  const MeditationControlsOverlay({
    super.key,
    required this.controller,
    required this.onEndConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    final isPaused = controller.state == SessionState.paused;

    return Container(
      color: Colors.black.withValues(alpha: 0.35),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppIconButton(
                    icon: Icon(
                      controller.isDimmed
                          ? Icons.brightness_high_rounded
                          : Icons.brightness_2_rounded,
                    ),
                    onPressed: controller.toggleDim,
                    tooltip: 'Toggle Dim Screen',
                    backgroundColor: Colors.black.withValues(alpha: 0.4),
                    iconColor: Colors.white,
                  ),
                  Text(
                    controller.practice.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                  AppIconButton(
                    icon: const Icon(Icons.volume_up_rounded),
                    onPressed: () => _showAudioSheet(context),
                    tooltip: 'Sound Options',
                    backgroundColor: Colors.black.withValues(alpha: 0.4),
                    iconColor: Colors.white,
                  ),
                ],
              ),
            ),

            // Center: Big Pause/Resume Button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    if (isPaused) {
                      controller.resume();
                    } else {
                      controller.pause();
                    }
                  },
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                        size: 38,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Bottom Bar: End Meditation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white.withValues(alpha: 0.85),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () => _confirmEndMeditation(context),
                    icon: const Icon(Icons.stop_rounded, size: 20),
                    label: const Text(
                      'End Meditation',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmEndMeditation(BuildContext context) async {
    final confirmed = await AppDialog.showConfirmation(
      context,
      title: 'End meditation?',
      content: 'Your current progress will be recorded in history.',
      confirmLabel: 'End session',
      cancelLabel: 'Continue meditating',
      isDestructive: true,
    );

    if (confirmed == true) {
      onEndConfirmed();
    }
  }

  void _showAudioSheet(BuildContext context) {
    AppSheet.show(
      context: context,
      title: 'Sound & Volume',
      child: StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Background Audio Volume',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ctx.textPrimaryColor,
                  ),
                ),
                Slider(
                  value: controller.audioService.bgPlayer.volume,
                  onChanged: (val) {
                    controller.audioService.setBackgroundVolume(val);
                    setSheetState(() {});
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
