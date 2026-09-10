import 'dart:math';
import 'package:flutter/material.dart';
import '../controllers/session_controller.dart';
import '../../../core/theme/app_theme.dart';

class BreathingOrb extends StatelessWidget {
  final BreathingPhase phase;
  final double progress; // 0.0 to 1.0 within the phase
  final double size;

  const BreathingOrb({
    super.key,
    required this.phase,
    required this.progress,
    this.size = 220.0,
  });

  @override
  Widget build(BuildContext context) {
    // Determine scale based on phase and progress
    double scale;
    switch (phase) {
      case BreathingPhase.inhale:
        // Expands from 0.6 to 1.0 with smooth easeInOut
        scale = 0.6 + 0.4 * _easeInOut(progress);
        break;
      case BreathingPhase.inhaleHold:
        // Stays expanded at 1.0 with subtle gentle pulsing
        scale = 1.0 + 0.03 * sin(progress * pi);
        break;
      case BreathingPhase.exhale:
        // Contracts from 1.0 to 0.6
        scale = 1.0 - 0.4 * _easeInOut(progress);
        break;
      case BreathingPhase.exhaleHold:
        // Stays contracted at 0.6
        scale = 0.6 + 0.02 * sin(progress * pi);
        break;
    }

    final accent = context.accentColor;

    return Semantics(
      label: 'Breathing animation: ${phase.label}',
      child: SizedBox(
        width: size,
        height: size,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            curve: Curves.linear,
            width: size * scale,
            height: size * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accent.withValues(alpha: 0.15),
                  accent.withValues(alpha: 0.35),
                  accent.withValues(alpha: 0.0),
                ],
                stops: const [0.4, 0.75, 1.0],
              ),
            ),
            child: Center(
              child: Container(
                width: (size * scale) * 0.65,
                height: (size * scale) * 0.65,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: 0.25),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _easeInOut(double t) {
    return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;
  }
}
