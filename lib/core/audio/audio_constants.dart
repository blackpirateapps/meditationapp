class SoundItem {
  final String id;
  final String title;
  final String category; // 'nature', 'noise', 'ambient', 'bell', 'silent'
  final String assetPath;

  const SoundItem({
    required this.id,
    required this.title,
    required this.category,
    required this.assetPath,
  });
}

class AudioConstants {
  static const none = SoundItem(
    id: 'none',
    title: 'Silent (No Sound)',
    category: 'silent',
    assetPath: '',
  );

  // Bells
  static const bellSingingBowl = SoundItem(
    id: 'bell_singing_bowl',
    title: 'Tibetan Singing Bowl',
    category: 'bell',
    assetPath: 'assets/audio/bell_singing_bowl.wav',
  );

  static const bellTingsha = SoundItem(
    id: 'bell_tingsha',
    title: 'Tingsha Cymbals',
    category: 'bell',
    assetPath: 'assets/audio/bell_tingsha.wav',
  );

  static const bellChime = SoundItem(
    id: 'bell_chime',
    title: 'Harmonic Chime',
    category: 'bell',
    assetPath: 'assets/audio/bell_chime.wav',
  );

  static const bellGong = SoundItem(
    id: 'bell_gong',
    title: 'Temple Gong',
    category: 'bell',
    assetPath: 'assets/audio/bell_gong.wav',
  );

  // Nature
  static const natureRain = SoundItem(
    id: 'nature_rain',
    title: 'Gentle Rain',
    category: 'nature',
    assetPath: 'assets/audio/nature_rain.wav',
  );

  static const natureOcean = SoundItem(
    id: 'nature_ocean',
    title: 'Ocean Swell',
    category: 'nature',
    assetPath: 'assets/audio/nature_ocean.wav',
  );

  static const natureForest = SoundItem(
    id: 'nature_forest',
    title: 'Forest Wind',
    category: 'nature',
    assetPath: 'assets/audio/nature_forest.wav',
  );

  static const natureFireplace = SoundItem(
    id: 'nature_fireplace',
    title: 'Warm Hearth',
    category: 'nature',
    assetPath: 'assets/audio/nature_fireplace.wav',
  );

  // Noise
  static const noiseBrown = SoundItem(
    id: 'noise_brown',
    title: 'Brown Noise',
    category: 'noise',
    assetPath: 'assets/audio/noise_brown.wav',
  );

  static const noisePink = SoundItem(
    id: 'noise_pink',
    title: 'Pink Noise',
    category: 'noise',
    assetPath: 'assets/audio/noise_pink.wav',
  );

  static const noiseWhite = SoundItem(
    id: 'noise_white',
    title: 'White Noise',
    category: 'noise',
    assetPath: 'assets/audio/noise_white.wav',
  );

  // Ambient
  static const ambientSoft = SoundItem(
    id: 'ambient_soft',
    title: 'Soft Ambient Drone',
    category: 'ambient',
    assetPath: 'assets/audio/ambient_soft.wav',
  );

  static const ambientDeep = SoundItem(
    id: 'ambient_deep',
    title: 'Deep Ambient Sub-Drone',
    category: 'ambient',
    assetPath: 'assets/audio/ambient_deep.wav',
  );

  static const List<SoundItem> allBells = [
    bellSingingBowl,
    bellTingsha,
    bellChime,
    bellGong,
  ];

  static const List<SoundItem> allBackgroundSounds = [
    none,
    natureRain,
    natureOcean,
    natureForest,
    natureFireplace,
    noiseBrown,
    noisePink,
    noiseWhite,
    ambientSoft,
    ambientDeep,
  ];

  static SoundItem getSoundById(String id) {
    if (id == 'none' || id.isEmpty) return none;
    for (final s in allBackgroundSounds) {
      if (s.id == id) return s;
    }
    for (final b in allBells) {
      if (b.id == id) return b;
    }
    return none;
  }
}
