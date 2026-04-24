import 'dart:math' as math;
import 'dart:typed_data';

class WaveformAmplitudeProcessor {
  static const double minAmplitude = 0.008;
  static const int _bytesPerSample = 2;
  static const int _maxSamplesPerWindow = 32;

  static const int _barsPerChunk = 2;
  static const double _attackFactor = 0.9;
  static const double _releaseFactor = 0.42;
  static const double _noiseFloorAttack = 0.1;
  static const double _noiseFloorRelease = 0.02;
  static const double _noiseGateThreshold = 0.006;
  static const double _noiseSuppression = 0.55;

  double _smoothedAmplitude = minAmplitude;
  double _noiseFloor = 0.0;

  List<double> processChunk(Uint8List bytes) {
    if (bytes.length < _bytesPerSample) {
      return const [minAmplitude];
    }

    final byteData = ByteData.sublistView(bytes);
    final sampleCount = bytes.length ~/ _bytesPerSample;
    final windowSize = math.max(1, sampleCount ~/ _barsPerChunk);
    final amplitudes = <double>[];

    for (var start = 0; start < sampleCount; start += windowSize) {
      final end = math.min(start + windowSize, sampleCount);
      final energy = _computeWindowEnergy(
        byteData,
        startSample: start,
        endSample: end,
      );
      final normalizedAmplitude = _normalizeEnergy(energy);

      amplitudes.add(_smoothAmplitude(normalizedAmplitude));
    }

    return amplitudes;
  }

  double _computeWindowEnergy(
    ByteData byteData, {
    required int startSample,
    required int endSample,
  }) {
    final sampleStride = math.max(
      1,
      (endSample - startSample) ~/ _maxSamplesPerWindow,
    );

    var peak = 0.0;
    var total = 0.0;
    var samplesSeen = 0;

    for (
      var sampleIndex = startSample;
      sampleIndex < endSample;
      sampleIndex += sampleStride
    ) {
      final sample = _readSample(byteData, sampleIndex);
      total += sample;
      samplesSeen++;
      peak = math.max(peak, sample);
    }

    if (samplesSeen == 0) {
      return 0.0;
    }

    final average = total / samplesSeen;
    return (average * 0.25) + (peak * 0.75);
  }

  double _readSample(ByteData byteData, int sampleIndex) {
    return byteData
            .getInt16(sampleIndex * _bytesPerSample, Endian.little)
            .abs() /
        32768.0;
  }

  double _normalizeEnergy(double energy) {
    _updateNoiseFloor(energy);

    final suppressedNoise =
        (_noiseFloor * _noiseSuppression) + _noiseGateThreshold;
    final gatedEnergy = math.max(0.0, energy - suppressedNoise);
    final availableHeadroom = math.max(0.12, 1 - suppressedNoise);
    final normalizedEnergy = (gatedEnergy / availableHeadroom).clamp(0.0, 1.0);
    final boostedEnergy = math.pow(normalizedEnergy, 0.32) as double;

    return math.max((boostedEnergy * 2.4).clamp(0.0, 1.0), minAmplitude);
  }

  void _updateNoiseFloor(double energy) {
    final followFactor =
        energy < _noiseFloor ? _noiseFloorAttack : _noiseFloorRelease;
    _noiseFloor = (_noiseFloor * (1 - followFactor)) + (energy * followFactor);
  }

  double _smoothAmplitude(double amplitude) {
    final smoothingFactor =
        amplitude > _smoothedAmplitude ? _attackFactor : _releaseFactor;
    _smoothedAmplitude =
        (_smoothedAmplitude * (1 - smoothingFactor)) +
        (amplitude * smoothingFactor);

    return math.max(_smoothedAmplitude, minAmplitude);
  }

  void reset() {
    _smoothedAmplitude = minAmplitude;
    _noiseFloor = 0.0;
  }
}
