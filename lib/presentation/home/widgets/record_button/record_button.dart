import 'package:flutter/material.dart';
import 'package:voice_memos/presentation/presentation.dart';

import 'record_ring_painter.dart';
import 'red_shape.dart';

class RecordButton extends StatefulWidget {
  static const size = 75.0;

  static const _segmentWidth = 2.0;
  static const _segmentHeight = 3.0;
  static const _ringColor = VoiceMemosColors.white;
  static const _rotationDuration = Duration(seconds: 15);

  final VoidCallback onTap;
  final bool recording;

  const RecordButton({required this.onTap, this.recording = false, super.key});

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: RecordButton._rotationDuration,
    );

    _syncAnimationState();
  }

  @override
  void didUpdateWidget(covariant RecordButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.recording == widget.recording) {
      return;
    }

    _syncAnimationState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _syncAnimationState() {
    if (widget.recording) {
      if (!_animationController.isAnimating) {
        _animationController.repeat();
      }
      return;
    }

    _animationController
      ..stop()
      ..reset();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: true,
      toggled: widget.recording,
      label: 'Record memo',
      hint: widget.recording
          ? 'Tap to stop recording'
          : 'Tap to start recording',
      child: SizedBox.square(
        dimension: RecordButton.size,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: RotationTransition(
                  turns: _animationController,
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: RecordRingPainter(
                        segmentWidth: RecordButton._segmentWidth,
                        segmentHeight: RecordButton._segmentHeight,
                        color: RecordButton._ringColor,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: RedShape(
                  recording: widget.recording,
                  size: RecordButton.size,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
