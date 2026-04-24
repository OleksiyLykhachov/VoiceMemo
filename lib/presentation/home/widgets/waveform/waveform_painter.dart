import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'waveform_timeline_controller.dart';

class WaveformPainter extends CustomPainter {
  static const _minBarHeight = 2.0;
  static const _maxBarHeightFactor = 0.94;
  static const _cursorHeightFactor = 0.78;
  static const _rightLaneAlpha = 0.28;

  final WaveformFrame fromFrame;
  final WaveformFrame toFrame;
  final double progress;
  final WaveformGeometry geometry;
  final Color barColor;
  final Color cursorColor;

  const WaveformPainter({
    required this.fromFrame,
    required this.toFrame,
    required this.progress,
    required this.geometry,
    required this.barColor,
    required this.cursorColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || geometry.barCountPerSide == 0) {
      return;
    }

    final centerX = size.width / 2;
    final leftRect = Rect.fromLTRB(
      0,
      0,
      centerX - (geometry.cursorWidth / 2) - geometry.cursorInset,
      size.height,
    );
    final rightRect = Rect.fromLTRB(
      centerX + (geometry.cursorWidth / 2) + geometry.cursorInset,
      0,
      size.width,
      size.height,
    );
    final shiftDistance = geometry.slotExtent * progress;

    _paintLeftLane(canvas, size, leftRect, shiftDistance);
    _paintRightLane(canvas, size, rightRect, shiftDistance);
    _paintCursor(canvas, size, centerX);
  }

  void _paintLeftLane(
    Canvas canvas,
    Size size,
    Rect laneRect,
    double shiftDistance,
  ) {
    final paint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final centerY = size.height / 2;
    final maxBarHeight = size.height * _maxBarHeightFactor;

    canvas.save();
    canvas.clipRect(laneRect);

    for (var index = 0; index < fromFrame.leftBars.length; index++) {
      final dx =
          laneRect.right -
          geometry.barWidth -
          ((fromFrame.leftBars.length - 1 - index) * geometry.slotExtent) -
          shiftDistance;
      _paintBar(
        canvas,
        paint,
        amplitude: fromFrame.leftBars[index],
        dx: dx,
        centerY: centerY,
        maxBarHeight: maxBarHeight,
      );
    }

    if (toFrame.leftBars.isNotEmpty) {
      _paintBar(
        canvas,
        paint,
        amplitude: toFrame.leftBars.last,
        dx: laneRect.right + geometry.slotExtent - geometry.barWidth - shiftDistance,
        centerY: centerY,
        maxBarHeight: maxBarHeight,
      );
    }

    canvas.restore();
  }

  void _paintRightLane(
    Canvas canvas,
    Size size,
    Rect laneRect,
    double shiftDistance,
  ) {
    final paint = Paint()
      ..color = barColor.withValues(alpha: _rightLaneAlpha)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final centerY = size.height / 2;
    final maxBarHeight = size.height * _maxBarHeightFactor;

    canvas.save();
    canvas.clipRect(laneRect);

    for (var index = 0; index < fromFrame.rightBars.length; index++) {
      final dx = laneRect.left + (index * geometry.slotExtent) - shiftDistance;
      _paintBar(
        canvas,
        paint,
        amplitude: fromFrame.rightBars[index],
        dx: dx,
        centerY: centerY,
        maxBarHeight: maxBarHeight,
      );
    }

    if (toFrame.rightBars.isNotEmpty) {
      _paintBar(
        canvas,
        paint,
        amplitude: toFrame.rightBars.last,
        dx: laneRect.left + (fromFrame.rightBars.length * geometry.slotExtent) - shiftDistance,
        centerY: centerY,
        maxBarHeight: maxBarHeight,
      );
    }

    canvas.restore();
  }

  void _paintBar(
    Canvas canvas,
    Paint paint, {
    required double amplitude,
    required double dx,
    required double centerY,
    required double maxBarHeight,
  }) {
    final barHeight = _barHeightForAmplitude(amplitude, maxBarHeight);
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(dx + (geometry.barWidth / 2), centerY),
        width: geometry.barWidth,
        height: barHeight,
      ),
      Radius.circular(geometry.barWidth),
    );
    canvas.drawRRect(rect, paint);
  }

  double _barHeightForAmplitude(double amplitude, double maxBarHeight) {
    final visualAmplitude =
        math.pow(amplitude.clamp(0.0, 1.0), 0.65) as double;
    return (_minBarHeight + ((maxBarHeight - _minBarHeight) * visualAmplitude))
        .clamp(_minBarHeight, maxBarHeight);
  }

  void _paintCursor(Canvas canvas, Size size, double centerX) {
    final paint = Paint()
      ..color = cursorColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, size.height / 2),
        width: geometry.cursorWidth,
        height: size.height * _cursorHeightFactor,
      ),
      Radius.circular(geometry.cursorWidth),
    );

    canvas.drawRRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.fromFrame != fromFrame ||
        oldDelegate.toFrame != toFrame ||
        oldDelegate.progress != progress ||
        oldDelegate.geometry != geometry ||
        oldDelegate.barColor != barColor ||
        oldDelegate.cursorColor != cursorColor;
  }
}
