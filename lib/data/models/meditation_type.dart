enum MeditationType {
  breathing,
  openAwareness,
  bodyScan,
  focus,
  mantra,
  walking,
  sleep,
  silentTimer;

  String get displayName {
    switch (this) {
      case MeditationType.breathing:
        return 'Breathing';
      case MeditationType.openAwareness:
        return 'Open Awareness';
      case MeditationType.bodyScan:
        return 'Body Scan';
      case MeditationType.focus:
        return 'Focus';
      case MeditationType.mantra:
        return 'Mantra';
      case MeditationType.walking:
        return 'Walking';
      case MeditationType.sleep:
        return 'Sleep';
      case MeditationType.silentTimer:
        return 'Silent Timer';
    }
  }

  String get description {
    switch (this) {
      case MeditationType.breathing:
        return 'Rhythmic breath regulation with guided pacing.';
      case MeditationType.openAwareness:
        return 'Effortless, spacious resting in the present moment.';
      case MeditationType.bodyScan:
        return 'Gentle sequential awareness moving through the body.';
      case MeditationType.focus:
        return 'Single-pointed attention anchored on a visual focal center.';
      case MeditationType.mantra:
        return 'Quiet visual contemplation of a resonant phrase or intention.';
      case MeditationType.walking:
        return 'Mindful movement and grounded presence in motion.';
      case MeditationType.sleep:
        return 'Deep relaxation, soothing ambient sounds, and dim display.';
      case MeditationType.silentTimer:
        return 'Unadorned stillness with customizable interval and ending bells.';
    }
  }

  static MeditationType fromString(String val) {
    return MeditationType.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => MeditationType.silentTimer,
    );
  }
}
