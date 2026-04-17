import 'dart:math' as math;

import 'package:flutter/material.dart';

class RecordRingPainter extends CustomPainter {
  static const _segmentCount = 60;

  final double segmentWidth;
  final double segmentHeight;
  final Color color;

  const RecordRingPainter({
    required this.segmentWidth,
    required this.segmentHeight,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || segmentWidth <= 0 || segmentHeight <= 0) {
      return;
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final center = size.center(Offset.zero);
    final diameter = size.shortestSide;
    final radius = (diameter - segmentHeight) / 2;

    if (radius <= 0) {
      return;
    }

    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(0, -radius),
        width: segmentWidth,
        height: segmentHeight,
      ),
      Radius.circular(segmentWidth / 2),
    );

    canvas.save();
    canvas.translate(center.dx, center.dy);

    for (var i = 0; i < RecordRingPainter._segmentCount; i++) {
      final angle = (2 * math.pi * i) / RecordRingPainter._segmentCount;
      canvas.save();
      canvas.rotate(angle);
      canvas.drawRRect(rect, paint);
      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant RecordRingPainter oldDelegate) {
    return oldDelegate.segmentWidth != segmentWidth ||
        oldDelegate.segmentHeight != segmentHeight ||
        oldDelegate.color != color;
  }
}
