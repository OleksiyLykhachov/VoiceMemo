import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:voice_memos/presentation/presentation.dart';

class RecordBackground extends SingleChildRenderObjectWidget {
  final double progress;
  final Color backgroundColor;
  final Color trackColor;
  final Color progressColor;
  final double contentInset;

  const RecordBackground({
    required this.progress,
    required super.child,
    this.contentInset = 0,
    this.backgroundColor = VoiceMemosColors.white,
    this.trackColor = VoiceMemosColors.black,
    this.progressColor = const Color(0x4D8A8A8A),
    super.key,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RecordBackgroundRenderObject(
      progress: progress.clamp(0.0, 1.0),
      backgroundColor: backgroundColor,
      trackColor: trackColor,
      progressColor: progressColor,
      contentInset: contentInset,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RecordBackgroundRenderObject renderObject,
  ) {
    renderObject
      ..progress = progress.clamp(0.0, 1.0)
      ..backgroundColor = backgroundColor
      ..trackColor = trackColor
      ..progressColor = progressColor
      ..contentInset = contentInset;
  }
}

class RecordBackgroundRenderObject extends RenderShiftedBox {
  static const _majorSegmentEvery = 15;
  static const _startAngle = 0.0;
  static const _strokeInset = 8.0;
  static const _minorSegmentWidth = 1.5;
  static const _majorSegmentWidth = 2.0;
  static const _minorSegmentLength = 13.0;
  static const _majorSegmentLength = 18.0;

  RecordBackgroundRenderObject({
    required double progress,
    required Color backgroundColor,
    required Color trackColor,
    required Color progressColor,
    required double contentInset,
    RenderBox? child,
  }) : _progress = progress,
       _backgroundColor = backgroundColor,
       _trackColor = trackColor,
       _progressColor = progressColor,
       _contentInset = contentInset < 0 ? 0.0 : contentInset,
       super(child);

  double _progress;
  Color _backgroundColor;
  Color _trackColor;
  Color _progressColor;
  double _contentInset;

  double get progress => _progress;
  set progress(double value) {
    if (_progress == value) {
      return;
    }
    _progress = value;
    markNeedsPaint();
  }

  Color get backgroundColor => _backgroundColor;
  set backgroundColor(Color value) {
    if (_backgroundColor == value) {
      return;
    }
    _backgroundColor = value;
    markNeedsPaint();
  }

  Color get trackColor => _trackColor;
  set trackColor(Color value) {
    if (_trackColor == value) {
      return;
    }
    _trackColor = value;
    markNeedsPaint();
  }

  Color get progressColor => _progressColor;
  set progressColor(Color value) {
    if (_progressColor == value) {
      return;
    }
    _progressColor = value;
    markNeedsPaint();
  }

  double get contentInset => _contentInset;
  set contentInset(double value) {
    final normalizedValue = value < 0 ? 0.0 : value;
    if (_contentInset == normalizedValue) {
      return;
    }
    _contentInset = normalizedValue;
    markNeedsLayout();
  }

  double _resolveSquareSide(BoxConstraints constraints) {
    final boundedWidth = constraints.hasBoundedWidth;
    final boundedHeight = constraints.hasBoundedHeight;

    if (boundedWidth && boundedHeight) {
      return math.min(constraints.maxWidth, constraints.maxHeight);
    }
    if (boundedWidth) {
      return constraints.maxWidth;
    }
    if (boundedHeight) {
      return constraints.maxHeight;
    }

    return math.max(constraints.minWidth, constraints.minHeight);
  }

  double _computeChildSide(double hostSide) {
    final radius = hostSide / 2;
    final safeRadius = radius - _contentInset;
    final constrainedRadius = math.max(0, safeRadius);
    return constrainedRadius * math.sqrt(2);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final squareSide = _resolveSquareSide(constraints);
    return constraints.constrain(Size.square(squareSide));
  }

  @override
  void performLayout() {
    size = computeDryLayout(constraints);

    final currentChild = child;
    if (currentChild == null) {
      return;
    }

    final childSide = _computeChildSide(size.shortestSide);
    currentChild.layout(
      BoxConstraints.tightFor(width: childSide, height: childSide),
      parentUsesSize: true,
    );

    final childParentData = currentChild.parentData! as BoxParentData;
    childParentData.offset = Offset(
      (size.width - currentChild.size.width) / 2,
      (size.height - currentChild.size.height) / 2,
    );
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final currentChild = child;
    if (currentChild == null) {
      return false;
    }

    final childParentData = currentChild.parentData! as BoxParentData;
    return result.addWithPaintOffset(
      offset: childParentData.offset,
      position: position,
      hitTest: (result, transformed) {
        return currentChild.hitTest(result, position: transformed);
      },
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (size.isEmpty) {
      return;
    }

    const segmentsCount = 240;

    final canvas = context.canvas;
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final backgroundPaint =
        Paint()
          ..color = _backgroundColor
          ..style = PaintingStyle.fill
          ..isAntiAlias = true;
    final segmentRadius = Radius.circular(_minorSegmentWidth / 2);
    final paintedSegments = (segmentsCount * _progress).round();

    final trackPaint =
        Paint()
          ..color = _trackColor
          ..style = PaintingStyle.fill
          ..isAntiAlias = true;
    final progressPaint =
        Paint()
          ..color = _progressColor
          ..style = PaintingStyle.fill
          ..isAntiAlias = true;

    canvas.drawCircle(offset + center, radius, backgroundPaint);

    canvas.save();
    canvas.translate(offset.dx + center.dx, offset.dy + center.dy);

    for (var i = 0; i < segmentsCount; i++) {
      final isMajor = i % _majorSegmentEvery == 0;
      final segmentLength = isMajor ? _majorSegmentLength : _minorSegmentLength;
      final segmentWidth = isMajor ? _majorSegmentWidth : _minorSegmentWidth;
      final segmentRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(0, -radius + _strokeInset + segmentLength / 2),
          width: segmentWidth,
          height: segmentLength,
        ),
        segmentRadius,
      );
      final angle = _startAngle + (2 * math.pi * i) / segmentsCount;
      canvas.save();
      canvas.rotate(angle);
      canvas.drawRRect(
        segmentRect,
        i < paintedSegments ? trackPaint : progressPaint,
      );
      canvas.restore();
    }

    canvas.restore();

    final currentChild = child;
    if (currentChild == null) {
      return;
    }

    final childParentData = currentChild.parentData! as BoxParentData;
    context.paintChild(currentChild, offset + childParentData.offset);
  }
}
