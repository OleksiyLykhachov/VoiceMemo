import 'dart:collection';
import 'dart:math' as math;

import 'package:collection/collection.dart';

import 'waveform_amplitude_processor.dart';

class WaveformTimelineController {
  static const double rightBaselineAmplitude = 0.01;
  static const double fallbackDecay = 0.86;

  final ListQueue<double> _pendingAmplitudes = ListQueue<double>();

  WaveformGeometry _geometry = const WaveformGeometry.empty();
  WaveformFrame _currentFrame = const WaveformFrame.empty();
  WaveformFrame _fromFrame = const WaveformFrame.empty();
  WaveformFrame _toFrame = const WaveformFrame.empty();
  double _lastRenderedAmplitude = WaveformAmplitudeProcessor.minAmplitude;

  WaveformGeometry get geometry => _geometry;
  WaveformFrame get fromFrame => _fromFrame;
  WaveformFrame get toFrame => _toFrame;

  bool get hasGeometry => _geometry.barCountPerSide > 0;

  bool syncGeometry(WaveformGeometry geometry) {
    if (_geometry == geometry) {
      return false;
    }

    _geometry = geometry;
    _trimPendingQueue();
    _currentFrame = _resizeFrame(_currentFrame);
    _fromFrame = _resizeFrame(_fromFrame);
    _toFrame = _resizeFrame(_toFrame);
    return true;
  }

  void enqueueAmplitude(double amplitude) {
    // Drop oldest queued values first so the cursor stays close to live input.
    while (_pendingAmplitudes.length >= _maxQueueSize) {
      _pendingAmplitudes.removeFirst();
    }
    _pendingAmplitudes.add(amplitude);
  }

  void prepareNextShift() {
    if (!hasGeometry) {
      return;
    }

    _fromFrame = _currentFrame;
    _toFrame = _buildNextFrame(_currentFrame);
  }

  void commitShift() {
    _currentFrame = _toFrame;
    _fromFrame = _currentFrame;
  }

  void reset() {
    _lastRenderedAmplitude = WaveformAmplitudeProcessor.minAmplitude;
    _pendingAmplitudes.clear();

    final baselineFrame = WaveformFrame.baseline(
      count: _geometry.barCountPerSide,
      baselineAmplitude: rightBaselineAmplitude,
    );
    _currentFrame = baselineFrame;
    _fromFrame = baselineFrame;
    _toFrame = baselineFrame;
  }

  WaveformFrame _buildNextFrame(WaveformFrame frame) {
    final nextLeftAmplitude =
        _pendingAmplitudes.isNotEmpty
            ? _pendingAmplitudes.removeFirst()
            : math.max(
              WaveformAmplitudeProcessor.minAmplitude,
              _lastRenderedAmplitude * fallbackDecay,
            );
    _lastRenderedAmplitude = nextLeftAmplitude;

    // Left lane keeps oldest->newest ordering, so the newest live bar is last.
    final nextLeftBars = List<double>.from(frame.leftBars)
      ..removeAt(0)
      ..add(nextLeftAmplitude);
    final nextRightBars = List<double>.from(frame.rightBars)
      ..removeAt(0)
      ..add(rightBaselineAmplitude);

    return WaveformFrame(leftBars: nextLeftBars, rightBars: nextRightBars);
  }

  WaveformFrame _resizeFrame(WaveformFrame frame) {
    if (!hasGeometry) {
      return const WaveformFrame.empty();
    }

    return WaveformFrame(
      leftBars: _resizeLeftBars(frame.leftBars),
      rightBars: List<double>.filled(
        _geometry.barCountPerSide,
        rightBaselineAmplitude,
      ),
    );
  }

  List<double> _resizeLeftBars(List<double> bars) {
    final targetCount = _geometry.barCountPerSide;
    if (targetCount == 0) {
      return const <double>[];
    }

    final result = List<double>.filled(targetCount, rightBaselineAmplitude);
    final copyCount = math.min(targetCount, bars.length);
    for (var i = 0; i < copyCount; i++) {
      result[targetCount - copyCount + i] = bars[bars.length - copyCount + i];
    }
    return result;
  }

  int get _maxQueueSize {
    if (!hasGeometry) {
      return 1;
    }
    return _geometry.barCountPerSide * 2;
  }

  void _trimPendingQueue() {
    while (_pendingAmplitudes.length > _maxQueueSize) {
      _pendingAmplitudes.removeFirst();
    }
  }
}

class WaveformFrame {
  final List<double> leftBars;
  final List<double> rightBars;

  const WaveformFrame({required this.leftBars, required this.rightBars});

  const WaveformFrame.empty()
    : leftBars = const <double>[],
      rightBars = const <double>[];

  factory WaveformFrame.baseline({
    required int count,
    required double baselineAmplitude,
  }) {
    return WaveformFrame(
      leftBars: List<double>.filled(count, baselineAmplitude),
      rightBars: List<double>.filled(count, baselineAmplitude),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is WaveformFrame &&
        _listEquals(other.leftBars, leftBars) &&
        _listEquals(other.rightBars, rightBars);
  }

  @override
  int get hashCode => Object.hash(_hashList(leftBars), _hashList(rightBars));
}

class WaveformGeometry {
  static const double _defaultBarWidth = 1.8;
  static const double _defaultGap = 2.2;
  static const double _defaultCursorWidth = 3.0;
  static const double _defaultCursorInset = 1.0;

  final int barCountPerSide;
  final double barWidth;
  final double gap;
  final double cursorWidth;
  final double cursorInset;

  const WaveformGeometry({
    required this.barCountPerSide,
    required this.barWidth,
    required this.gap,
    required this.cursorWidth,
    required this.cursorInset,
  });

  const WaveformGeometry.empty()
    : barCountPerSide = 0,
      barWidth = _defaultBarWidth,
      gap = _defaultGap,
      cursorWidth = _defaultCursorWidth,
      cursorInset = _defaultCursorInset;

  factory WaveformGeometry.fromWidth(double width) {
    final halfWidth = width / 2;
    final laneWidth = math.max(
      0.0,
      halfWidth - (_defaultCursorWidth / 2) - _defaultCursorInset,
    );
    if (laneWidth <= 0) {
      return const WaveformGeometry.empty();
    }

    final slotExtent = _defaultBarWidth + _defaultGap;
    final barCount = math.max(1, ((laneWidth + _defaultGap) / slotExtent).floor());
    final freeSpace = math.max(0.0, laneWidth - (barCount * _defaultBarWidth));
    final resolvedGap = barCount <= 1 ? 0.0 : freeSpace / (barCount - 1);

    return WaveformGeometry(
      barCountPerSide: barCount,
      barWidth: _defaultBarWidth,
      gap: resolvedGap,
      cursorWidth: _defaultCursorWidth,
      cursorInset: _defaultCursorInset,
    );
  }

  double get slotExtent => barWidth + gap;

  @override
  bool operator ==(Object other) {
    return other is WaveformGeometry &&
        other.barCountPerSide == barCountPerSide &&
        other.barWidth == barWidth &&
        other.gap == gap &&
        other.cursorWidth == cursorWidth &&
        other.cursorInset == cursorInset;
  }

  @override
  int get hashCode => Object.hash(
    barCountPerSide,
    barWidth,
    gap,
    cursorWidth,
    cursorInset,
  );
}


const ListEquality<double> _doubleListEquality = ListEquality<double>();

bool _listEquals(List<double> a, List<double> b) =>
    _doubleListEquality.equals(a, b);

int _hashList(List<double> values) {
  return Object.hashAll(values);
}
