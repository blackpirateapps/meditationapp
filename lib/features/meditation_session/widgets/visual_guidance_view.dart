import 'package:flutter/material.dart';
import '../../../data/models/meditation_type.dart';
import '../controllers/session_controller.dart';
import '../../../core/theme/app_theme.dart';
import 'breathing_orb.dart';

class VisualGuidanceView extends StatelessWidget {
  final SessionController controller;

  const VisualGuidanceView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final type = controller.practice.type;

    switch (type) {
      case MeditationType.breathing:
        return _buildBreathingView(context);
      case MeditationType.bodyScan:
        return _buildBodyScanView(context);
      case MeditationType.focus:
        return _buildFocusView(context);
      case MeditationType.mantra:
        return _buildMantraView(context);
      case MeditationType.walking:
        return _buildWalkingView(context);
      case MeditationType.openAwareness:
        return _buildOpenAwarenessView(context);
      case MeditationType.sleep:
        return _buildSleepView(context);
      case MeditationType.silentTimer:
        return _buildSilentTimerView(context);
    }
  }

  Widget _buildBreathingView(BuildContext context) {
    final phase = controller.currentBreathingPhase;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        BreathingOrb(
          phase: phase,
          progress: controller.breathingPhaseProgress,
          size: 240,
        ),
        const SizedBox(height: 36),
        Text(
          phase.label.toUpperCase(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.4,
            color: context.textPrimaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildBodyScanView(BuildContext context) {
    final bodyParts = controller.practice.bodyScanConfig?.bodyParts ??
        const ['Whole Body Integration'];
    final idx = controller.currentBodyScanIndex;
    final currentPart = bodyParts.isNotEmpty ? bodyParts[idx] : 'Present Moment';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.accentColor.withValues(alpha: 0.12),
            border: Border.all(
              color: context.accentColor.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.accessibility_new_rounded,
              size: 34,
              color: context.accentColor,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'BRING AWARENESS TO',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.8,
            color: context.textTertiaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          currentPart,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.4,
            color: context.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Part ${idx + 1} of ${bodyParts.length}',
          style: TextStyle(
            fontSize: 13,
            color: context.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFocusView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.accentColor,
            boxShadow: [
              BoxShadow(
                color: context.accentColor.withValues(alpha: 0.4),
                blurRadius: 18,
                spreadRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
        Text(
          'Single-Pointed Focus',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
            color: context.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMantraView(BuildContext context) {
    final mantraText =
        controller.practice.mantraConfig?.mantraText ?? 'Peace begins with me';
    final pulse = controller.mantraPulse;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedScale(
          scale: pulse ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              mantraText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.2,
                color: pulse
                    ? context.textPrimaryColor
                    : context.textSecondaryColor,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWalkingView(BuildContext context) {
    final phases = controller.practice.walkingConfig?.walkingPhases ??
        const ['Mindful Steps'];
    final idx = controller.currentWalkingPhaseIndex;
    final currentPhase = phases.isNotEmpty ? phases[idx] : 'Mindful Steps';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.directions_walk_rounded,
          size: 48,
          color: context.accentColor,
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36.0),
          child: Text(
            currentPhase,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.3,
              color: context.textPrimaryColor,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOpenAwarenessView(BuildContext context) {
    return Center(
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.textTertiaryColor.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  Widget _buildSleepView(BuildContext context) {
    return Center(
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
    );
  }

  Widget _buildSilentTimerView(BuildContext context) {
    return Center(
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.textTertiaryColor.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
