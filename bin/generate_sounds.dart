// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

void main() {
  final outDir = Directory('assets/audio');
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }

  print('Generating audio assets...');

  // 1. Meditation Bells (one-shots with decay)
  _generateSingingBowl('${outDir.path}/bell_singing_bowl.wav', durationSec: 5.0);
  _generateTingsha('${outDir.path}/bell_tingsha.wav', durationSec: 4.5);
  _generateChime('${outDir.path}/bell_chime.wav', durationSec: 4.0);
  _generateGong('${outDir.path}/bell_gong.wav', durationSec: 6.0);

  // 2. Nature Sounds (loopable ~12-14s)
  _generateRain('${outDir.path}/nature_rain.wav', durationSec: 12.0);
  _generateOcean('${outDir.path}/nature_ocean.wav', durationSec: 14.0);
  _generateForest('${outDir.path}/nature_forest.wav', durationSec: 12.0);
  _generateFireplace('${outDir.path}/nature_fireplace.wav', durationSec: 12.0);

  // 3. Noise (loopable ~10s)
  _generateWhiteNoise('${outDir.path}/noise_white.wav', durationSec: 10.0);
  _generatePinkNoise('${outDir.path}/noise_pink.wav', durationSec: 10.0);
  _generateBrownNoise('${outDir.path}/noise_brown.wav', durationSec: 10.0);

  // 4. Ambient Drones (loopable ~12s)
  _generateSoftAmbient('${outDir.path}/ambient_soft.wav', durationSec: 12.0);
  _generateDeepAmbient('${outDir.path}/ambient_deep.wav', durationSec: 12.0);

  print('All audio assets generated successfully in ${outDir.path}');
}

void _writeWav(String path, List<double> samples, {int sampleRate = 44100, int numChannels = 2}) {
  final file = File(path);
  final byteData = ByteData(44 + samples.length * 2);

  double maxAmp = 0.0;
  for (final s in samples) {
    final abs = s.abs();
    if (abs > maxAmp) maxAmp = abs;
  }
  final scale = maxAmp > 0 ? (0.85 / maxAmp) : 1.0;

  // RIFF chunk
  _writeString(byteData, 0, 'RIFF');
  byteData.setUint32(4, 36 + samples.length * 2, Endian.little);
  _writeString(byteData, 8, 'WAVE');

  // fmt chunk
  _writeString(byteData, 12, 'fmt ');
  byteData.setUint32(16, 16, Endian.little);
  byteData.setUint16(20, 1, Endian.little); // PCM
  byteData.setUint16(22, numChannels, Endian.little);
  byteData.setUint32(24, sampleRate, Endian.little);
  byteData.setUint32(28, sampleRate * numChannels * 2, Endian.little);
  byteData.setUint16(32, numChannels * 2, Endian.little);
  byteData.setUint16(34, 16, Endian.little);

  // data chunk
  _writeString(byteData, 36, 'data');
  byteData.setUint32(40, samples.length * 2, Endian.little);

  int offset = 44;
  for (int i = 0; i < samples.length; i++) {
    final val = (samples[i] * scale).clamp(-1.0, 1.0);
    final int16 = (val * 32767.0).toInt();
    byteData.setInt16(offset, int16, Endian.little);
    offset += 2;
  }

  file.writeAsBytesSync(byteData.buffer.asUint8List());
}

void _writeString(ByteData bd, int offset, String s) {
  for (int i = 0; i < s.length; i++) {
    bd.setUint8(offset + i, s.codeUnitAt(i));
  }
}

void _generateSingingBowl(String path, {double durationSec = 5.0}) {
  const sampleRate = 44100;
  final totalSamples = (durationSec * sampleRate).toInt();
  final samples = List<double>.filled(totalSamples * 2, 0.0);

  final baseFreq = 216.0;
  final partials = [1.0, 2.76, 5.40, 8.92];
  final weights = [1.0, 0.5, 0.25, 0.1];
  final decayRates = [0.8, 1.4, 2.2, 3.5];

  for (int i = 0; i < totalSamples; i++) {
    final t = i / sampleRate;
    double sampleL = 0.0;
    double sampleR = 0.0;

    for (int p = 0; p < partials.length; p++) {
      final f = baseFreq * partials[p];
      final env = exp(-decayRates[p] * t);
      final sL = sin(2 * pi * f * t) * weights[p] * env;
      final sR = sin(2 * pi * (f + 0.35) * t) * weights[p] * env;
      sampleL += sL;
      sampleR += sR;
    }

    if (t < 0.05) {
      final strike = sin(2 * pi * 800 * t) * exp(-80 * t) * 0.4;
      sampleL += strike;
      sampleR += strike;
    }

    samples[i * 2] = sampleL;
    samples[i * 2 + 1] = sampleR;
  }
  _writeWav(path, samples, sampleRate: sampleRate);
}

void _generateTingsha(String path, {double durationSec = 4.5}) {
  const sampleRate = 44100;
  final totalSamples = (durationSec * sampleRate).toInt();
  final samples = List<double>.filled(totalSamples * 2, 0.0);

  final f1 = 2048.0;
  final f2 = 2056.0;
  final fOver = 4096.0;

  for (int i = 0; i < totalSamples; i++) {
    final t = i / sampleRate;
    final env = exp(-0.9 * t);
    final overEnv = exp(-2.5 * t);

    final s1 = sin(2 * pi * f1 * t) * 0.6 * env;
    final s2 = sin(2 * pi * f2 * t) * 0.6 * env;
    final overtone = sin(2 * pi * fOver * t) * 0.15 * overEnv;

    samples[i * 2] = s1 + overtone;
    samples[i * 2 + 1] = s2 + overtone;
  }
  _writeWav(path, samples, sampleRate: sampleRate);
}

void _generateChime(String path, {double durationSec = 4.0}) {
  const sampleRate = 44100;
  final totalSamples = (durationSec * sampleRate).toInt();
  final samples = List<double>.filled(totalSamples * 2, 0.0);

  final freqs = [528.0, 660.0, 792.0];
  final delays = [0.0, 0.08, 0.16];

  for (int i = 0; i < totalSamples; i++) {
    final t = i / sampleRate;
    double sL = 0.0;
    double sR = 0.0;

    for (int k = 0; k < 3; k++) {
      if (t >= delays[k]) {
        final localT = t - delays[k];
        final env = exp(-1.2 * localT);
        final val = sin(2 * pi * freqs[k] * localT) * env;
        final pan = -0.3 + 0.3 * k;
        sL += val * (0.5 - pan * 0.5);
        sR += val * (0.5 + pan * 0.5);
      }
    }

    samples[i * 2] = sL;
    samples[i * 2 + 1] = sR;
  }
  _writeWav(path, samples, sampleRate: sampleRate);
}

void _generateGong(String path, {double durationSec = 6.0}) {
  const sampleRate = 44100;
  final totalSamples = (durationSec * sampleRate).toInt();
  final samples = List<double>.filled(totalSamples * 2, 0.0);

  final baseFreq = 108.0;
  final partials = [1.0, 1.48, 2.05, 2.82, 3.65];
  final weights = [1.0, 0.8, 0.6, 0.4, 0.2];

  for (int i = 0; i < totalSamples; i++) {
    final t = i / sampleRate;
    double valL = 0.0;
    double valR = 0.0;

    for (int p = 0; p < partials.length; p++) {
      final f = baseFreq * partials[p];
      final env = exp(-0.6 * (1 + p * 0.3) * t);
      valL += sin(2 * pi * f * t) * weights[p] * env;
      valR += sin(2 * pi * (f + 0.2) * t) * weights[p] * env;
    }

    samples[i * 2] = valL;
    samples[i * 2 + 1] = valR;
  }
  _writeWav(path, samples, sampleRate: sampleRate);
}

void _generateRain(String path, {double durationSec = 12.0}) {
  const sampleRate = 44100;
  final totalSamples = (durationSec * sampleRate).toInt();
  final samples = List<double>.filled(totalSamples * 2, 0.0);
  final rng = Random(42);

  double b0 = 0, b1 = 0, b2 = 0, b3 = 0, b4 = 0, b5 = 0, b6 = 0;
  for (int i = 0; i < totalSamples; i++) {
    final white = (rng.nextDouble() * 2 - 1);
    b0 = 0.99886 * b0 + white * 0.0555179;
    b1 = 0.99332 * b1 + white * 0.0750759;
    b2 = 0.96900 * b2 + white * 0.1538520;
    b3 = 0.86650 * b3 + white * 0.3104856;
    b4 = 0.55000 * b4 + white * 0.5329522;
    b5 = -0.7616 * b5 - white * 0.0168980;
    final pink = (b0 + b1 + b2 + b3 + b4 + b5 + b6 + white * 0.5362) * 0.11;
    b6 = white * 0.115926;

    final t = i / sampleRate;
    double loopGain = 1.0;
    if (t < 0.5) loopGain = t / 0.5;
    if (t > durationSec - 0.5) loopGain = (durationSec - t) / 0.5;

    double dropL = 0;
    double dropR = 0;
    if (rng.nextDouble() < 0.003) {
      final amp = rng.nextDouble() * 0.3;
      dropL = amp;
      dropR = amp * (rng.nextDouble() * 0.8 + 0.2);
    }

    samples[i * 2] = (pink * 0.6 + dropL) * loopGain;
    samples[i * 2 + 1] = (pink * 0.6 + dropR) * loopGain;
  }
  _writeWav(path, samples, sampleRate: sampleRate);
}

void _generateOcean(String path, {double durationSec = 14.0}) {
  const sampleRate = 44100;
  final totalSamples = (durationSec * sampleRate).toInt();
  final samples = List<double>.filled(totalSamples * 2, 0.0);
  final rng = Random(123);

  double brown = 0.0;
  for (int i = 0; i < totalSamples; i++) {
    final white = rng.nextDouble() * 2 - 1;
    brown = (brown + (0.02 * white)) / 1.02;

    final t = i / sampleRate;
    final waveMod = 0.35 + 0.65 * pow(sin(2 * pi * t / 7.0), 2);

    double loopGain = 1.0;
    if (t < 0.5) loopGain = t / 0.5;
    if (t > durationSec - 0.5) loopGain = (durationSec - t) / 0.5;

    final s = brown * 5.0 * waveMod * loopGain;
    samples[i * 2] = s;
    samples[i * 2 + 1] = s * 0.95;
  }
  _writeWav(path, samples, sampleRate: sampleRate);
}

void _generateForest(String path, {double durationSec = 12.0}) {
  const sampleRate = 44100;
  final totalSamples = (durationSec * sampleRate).toInt();
  final samples = List<double>.filled(totalSamples * 2, 0.0);
  final rng = Random(99);

  double lowWind = 0.0;
  for (int i = 0; i < totalSamples; i++) {
    final white = rng.nextDouble() * 2 - 1;
    lowWind = (lowWind + (0.015 * white)) / 1.015;

    final t = i / sampleRate;
    final breezeMod = 0.4 + 0.6 * sin(2 * pi * t / 6.0);

    double chime = 0.0;
    if ((t > 3.0 && t < 3.8) || (t > 8.0 && t < 8.8)) {
      final ct = t % 5.0;
      chime = sin(2 * pi * 1760 * ct) * exp(-4.0 * (ct - 3.0).abs()) * 0.06;
    }

    double loopGain = 1.0;
    if (t < 0.5) loopGain = t / 0.5;
    if (t > durationSec - 0.5) loopGain = (durationSec - t) / 0.5;

    samples[i * 2] = (lowWind * 4.0 * breezeMod + chime) * loopGain;
    samples[i * 2 + 1] = (lowWind * 4.0 * breezeMod + chime * 0.8) * loopGain;
  }
  _writeWav(path, samples, sampleRate: sampleRate);
}

void _generateFireplace(String path, {double durationSec = 12.0}) {
  const sampleRate = 44100;
  final totalSamples = (durationSec * sampleRate).toInt();
  final samples = List<double>.filled(totalSamples * 2, 0.0);
  final rng = Random(55);

  double lowRoar = 0.0;
  for (int i = 0; i < totalSamples; i++) {
    final white = rng.nextDouble() * 2 - 1;
    lowRoar = (lowRoar + (0.02 * white)) / 1.02;

    double crackle = 0.0;
    if (rng.nextDouble() < 0.0008) {
      crackle = (rng.nextDouble() * 2 - 1) * 0.6;
    }

    final t = i / sampleRate;
    double loopGain = 1.0;
    if (t < 0.5) loopGain = t / 0.5;
    if (t > durationSec - 0.5) loopGain = (durationSec - t) / 0.5;

    final s = (lowRoar * 3.5 + crackle) * loopGain;
    samples[i * 2] = s;
    samples[i * 2 + 1] = s;
  }
  _writeWav(path, samples, sampleRate: sampleRate);
}

void _generateWhiteNoise(String path, {double durationSec = 10.0}) {
  const sampleRate = 44100;
  final totalSamples = (durationSec * sampleRate).toInt();
  final samples = List<double>.filled(totalSamples * 2, 0.0);
  final rng = Random(1);

  for (int i = 0; i < totalSamples; i++) {
    final t = i / sampleRate;
    double loopGain = 1.0;
    if (t < 0.5) loopGain = t / 0.5;
    if (t > durationSec - 0.5) loopGain = (durationSec - t) / 0.5;

    final s = (rng.nextDouble() * 2 - 1) * 0.25 * loopGain;
    samples[i * 2] = s;
    samples[i * 2 + 1] = s;
  }
  _writeWav(path, samples, sampleRate: sampleRate);
}

void _generatePinkNoise(String path, {double durationSec = 10.0}) {
  const sampleRate = 44100;
  final totalSamples = (durationSec * sampleRate).toInt();
  final samples = List<double>.filled(totalSamples * 2, 0.0);
  final rng = Random(2);

  double b0 = 0, b1 = 0, b2 = 0, b3 = 0, b4 = 0, b5 = 0, b6 = 0;
  for (int i = 0; i < totalSamples; i++) {
    final white = rng.nextDouble() * 2 - 1;
    b0 = 0.99886 * b0 + white * 0.0555179;
    b1 = 0.99332 * b1 + white * 0.0750759;
    b2 = 0.96900 * b2 + white * 0.1538520;
    b3 = 0.86650 * b3 + white * 0.3104856;
    b4 = 0.55000 * b4 + white * 0.5329522;
    b5 = -0.7616 * b5 - white * 0.0168980;
    final pink = (b0 + b1 + b2 + b3 + b4 + b5 + b6 + white * 0.5362) * 0.14;
    b6 = white * 0.115926;

    final t = i / sampleRate;
    double loopGain = 1.0;
    if (t < 0.5) loopGain = t / 0.5;
    if (t > durationSec - 0.5) loopGain = (durationSec - t) / 0.5;

    samples[i * 2] = pink * loopGain;
    samples[i * 2 + 1] = pink * loopGain;
  }
  _writeWav(path, samples, sampleRate: sampleRate);
}

void _generateBrownNoise(String path, {double durationSec = 10.0}) {
  const sampleRate = 44100;
  final totalSamples = (durationSec * sampleRate).toInt();
  final samples = List<double>.filled(totalSamples * 2, 0.0);
  final rng = Random(3);

  double brown = 0.0;
  for (int i = 0; i < totalSamples; i++) {
    final white = rng.nextDouble() * 2 - 1;
    brown = (brown + (0.02 * white)) / 1.02;

    final t = i / sampleRate;
    double loopGain = 1.0;
    if (t < 0.5) loopGain = t / 0.5;
    if (t > durationSec - 0.5) loopGain = (durationSec - t) / 0.5;

    final s = brown * 3.5 * loopGain;
    samples[i * 2] = s;
    samples[i * 2 + 1] = s;
  }
  _writeWav(path, samples, sampleRate: sampleRate);
}

void _generateSoftAmbient(String path, {double durationSec = 12.0}) {
  const sampleRate = 44100;
  final totalSamples = (durationSec * sampleRate).toInt();
  final samples = List<double>.filled(totalSamples * 2, 0.0);

  final freqs = [130.81, 196.00, 329.63];

  for (int i = 0; i < totalSamples; i++) {
    final t = i / sampleRate;
    double sL = 0;
    double sR = 0;

    for (final f in freqs) {
      sL += sin(2 * pi * f * t) * 0.25;
      sR += sin(2 * pi * (f + 0.25) * t) * 0.25;
    }

    final lfo = 0.7 + 0.3 * sin(2 * pi * t / durationSec);
    double loopGain = 1.0;
    if (t < 0.5) loopGain = t / 0.5;
    if (t > durationSec - 0.5) loopGain = (durationSec - t) / 0.5;

    samples[i * 2] = sL * lfo * loopGain;
    samples[i * 2 + 1] = sR * lfo * loopGain;
  }
  _writeWav(path, samples, sampleRate: sampleRate);
}

void _generateDeepAmbient(String path, {double durationSec = 12.0}) {
  const sampleRate = 44100;
  final totalSamples = (durationSec * sampleRate).toInt();
  final samples = List<double>.filled(totalSamples * 2, 0.0);

  final f = 65.41;

  for (int i = 0; i < totalSamples; i++) {
    final t = i / sampleRate;
    final sub = sin(2 * pi * f * t) * 0.5;
    final harmonic = sin(2 * pi * (f * 2) * t) * 0.2;
    final shimmer = sin(2 * pi * (f * 3 + 0.1) * t) * 0.1;

    final lfo = 0.8 + 0.2 * sin(2 * pi * t / (durationSec / 2));
    double loopGain = 1.0;
    if (t < 0.5) loopGain = t / 0.5;
    if (t > durationSec - 0.5) loopGain = (durationSec - t) / 0.5;

    final s = (sub + harmonic + shimmer) * lfo * loopGain;
    samples[i * 2] = s;
    samples[i * 2 + 1] = s * 0.98;
  }
  _writeWav(path, samples, sampleRate: sampleRate);
}
