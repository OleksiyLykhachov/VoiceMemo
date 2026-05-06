import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:voice_memos/presentation/presentation.dart';
import 'package:voice_memos/utils/utils.dart';

import 'waveform_painter.dart';
import 'waveform_timeline_controller.dart';

class Waveform extends StatefulWidget {
  const Waveform({
    required this.stream,
    super.key,
  });

  final Stream<AmplitudeData>? stream;

  @override
  State<Waveform> createState() => _WaveformState();
}

class _WaveformState extends State<Waveform>
    with SingleTickerProviderStateMixin {
  static const _shiftAnimationDuration = Duration(milliseconds: 44);

  late final WaveformTimelineController _timelineController;
  late final AnimationController _shiftController;
  StreamSubscription<AmplitudeData>? _audioSubscription;

  bool _isRecording = false;
  bool _shiftLoopActive = false;

  @override
  void initState() {
    super.initState();
    _timelineController = WaveformTimelineController()..reset();
    _shiftController =
        AnimationController(
          vsync: this,
          duration: _shiftAnimationDuration,
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _commitShiftAndContinue();
          }
        });
    _subscribeToStream(widget.stream);
  }

  @override
  void didUpdateWidget(covariant Waveform oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (identical(oldWidget.stream, widget.stream)) {
      return;
    }

    unawaited(_replaceStream(widget.stream));
  }

  @override
  void dispose() {
    unawaited(_audioSubscription?.cancel());
    _audioSubscription = null;
    _stopStreamDrivenAnimation();
    _shiftController.dispose();
    super.dispose();
  }

  Future<void> _replaceStream(Stream<AmplitudeData>? stream) async {
    final subscription = _audioSubscription;
    _audioSubscription = null;
    await subscription?.cancel();

    _stopStreamDrivenAnimation();

    if (!mounted) {
      return;
    }

    if (stream != null) {
      _resetWaveform();
    }

    _subscribeToStream(stream);
  }

  void _onAmplitudeData(AmplitudeData amplitudeData) {
    if (!mounted) {
      return;
    }

    _timelineController.enqueueAmplitude(_normalizeAmplitude(amplitudeData));
  }

  void _onStreamDone() {
    _handleStreamClosed();
  }

  void _onStreamError(Object error, StackTrace stackTrace) {
    _handleStreamClosed();
  }

  void _handleWaveformSizeChanged(Size size) {
    final geometry = WaveformGeometry.fromWidth(size.width);
    final didChange = _timelineController.syncGeometry(geometry);
    if (!didChange) {
      return;
    }

    _startShiftLoopIfNeeded();
    if (mounted) {
      setState(() {});
    }
  }

  void _startShiftLoopIfNeeded() {
    if (!_isRecording ||
        _shiftLoopActive ||
        !_timelineController.hasGeometry ||
        _shiftController.isAnimating) {
      return;
    }

    _shiftLoopActive = true;
    _runNextShift();
  }

  void _runNextShift() {
    if (!_isRecording || !_timelineController.hasGeometry) {
      _shiftLoopActive = false;
      return;
    }

    _timelineController.prepareNextShift();
    _shiftController.forward(from: 0);
  }

  void _commitShiftAndContinue() {
    _timelineController.commitShift();
    _shiftController.value = 0;

    if (!_isRecording || !mounted) {
      _shiftLoopActive = false;
      return;
    }

    _runNextShift();
  }

  void _subscribeToStream(Stream<AmplitudeData>? stream) {
    if (stream == null) {
      return;
    }

    _audioSubscription = stream.listen(
      _onAmplitudeData,
      onError: _onStreamError,
      onDone: _onStreamDone,
      cancelOnError: true,
    );
    _isRecording = true;
    _startShiftLoopIfNeeded();

    if (!mounted) {
      return;
    }

    setState(() {});
  }

  void _handleStreamClosed() {
    _audioSubscription = null;
    _stopStreamDrivenAnimation();

    if (!mounted) {
      return;
    }

    setState(() {});
  }

  void _resetWaveform() {
    _timelineController.reset();
  }

  double _normalizeAmplitude(AmplitudeData amplitudeData) {
    final current = amplitudeData.current;
    final max = amplitudeData.max;

    if (!current.isFinite) {
      return kWaveformMinAmplitude;
    }

    final currentLinear = _dbToLinear(current);
    if (!max.isFinite) {
      return currentLinear;
    }

    final maxLinear = _dbToLinear(max);
    final normalized =
        maxLinear > 0 ? (currentLinear / maxLinear) : currentLinear;
    if (!normalized.isFinite) {
      return kWaveformMinAmplitude;
    }

    return math.max(normalized.clamp(0.0, 1.0), kWaveformMinAmplitude);
  }

  double _dbToLinear(double value) {
    final clampedDb = value.clamp(-160.0, 0.0);
    final linear = math.pow(10, clampedDb / 20) as double;
    return linear.isFinite ? linear : kWaveformMinAmplitude;
  }

  void _stopStreamDrivenAnimation() {
    _isRecording = false;
    _shiftLoopActive = false;
    _shiftController.stop();
    _shiftController.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: double.infinity,
      child: RepaintBoundary(
        child: _MeasureSize(
          onChange: _handleWaveformSizeChanged,
          child: AnimatedBuilder(
            animation: _shiftController,
            builder: (context, child) {
              return CustomPaint(
                painter: WaveformPainter(
                  fromFrame: _timelineController.fromFrame,
                  toFrame: _timelineController.toFrame,
                  progress: _shiftController.value,
                  geometry: _timelineController.geometry,
                  barColor: VoiceMemosColors.white,
                  cursorColor: VoiceMemosColors.red,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MeasureSize extends SingleChildRenderObjectWidget {
  final ValueChanged<Size> onChange;

  const _MeasureSize({
    required this.onChange,
    required super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMeasureSize(onChange);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderMeasureSize renderObject,
  ) {
    renderObject.onChange = onChange;
  }
}

class _RenderMeasureSize extends RenderProxyBox {
  _RenderMeasureSize(this.onChange);

  ValueChanged<Size> onChange;
  Size? _lastSize;

  @override
  void performLayout() {
    super.performLayout();

    final newSize = child?.size;
    if (newSize == null || newSize == _lastSize) {
      return;
    }

    _lastSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onChange(newSize);
    });
  }
}
