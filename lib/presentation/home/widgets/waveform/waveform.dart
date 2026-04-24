import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:voice_memos/presentation/presentation.dart';

import 'waveform_amplitude_processor.dart';
import 'waveform_painter.dart';
import 'waveform_timeline_controller.dart';

class Waveform extends StatefulWidget {
  const Waveform({
    required this.stream,
    super.key,
  });

  final Stream<Uint8List>? stream;

  @override
  State<Waveform> createState() => _WaveformState();
}

class _WaveformState extends State<Waveform>
    with SingleTickerProviderStateMixin {
  static const _shiftAnimationDuration = Duration(milliseconds: 44);

  late final WaveformAmplitudeProcessor _amplitudeProcessor;
  late final WaveformTimelineController _timelineController;
  late final AnimationController _shiftController;
  StreamSubscription<Uint8List>? _audioSubscription;

  bool _isRecording = false;
  bool _shiftLoopActive = false;

  @override
  void initState() {
    super.initState();
    _amplitudeProcessor = WaveformAmplitudeProcessor();
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

  Future<void> _replaceStream(Stream<Uint8List>? stream) async {
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

  void _onAudioChunk(Uint8List chunk) {
    if (!mounted) {
      return;
    }

    final amplitudes = _amplitudeProcessor.processChunk(chunk);
    for (final amplitude in amplitudes) {
      _timelineController.enqueueAmplitude(amplitude);
    }
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

  void _subscribeToStream(Stream<Uint8List>? stream) {
    if (stream == null) {
      return;
    }

    _audioSubscription = stream.listen(
      _onAudioChunk,
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
    _amplitudeProcessor.reset();
    _timelineController.reset();
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
