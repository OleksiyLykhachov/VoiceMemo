import 'dart:math' as math;

import 'package:flutter/material.dart';

class RecordPanelShapePainter extends CustomPainter {
  static const defaultShoulderRadius = 36.0;
  static const _buttonBackgroundScale = 1.35;

  final Color color;
  final double buttonCenterY;
  final double buttonRadius;
  final double shoulderRadius;

  const RecordPanelShapePainter({
    required this.color,
    required this.buttonCenterY,
    required this.buttonRadius,
    this.shoulderRadius = defaultShoulderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }

    final path = _buildPath(size);
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill
          ..isAntiAlias = true;

    canvas.drawPath(path, paint);
  }

  Path _buildPath(Size size) {
    final width = size.width;
    final height = size.height;
    final topY = buttonCenterY.clamp(0.0, height).toDouble();
    final centerX = width / 2;
    final availableHeight = math.max(0.0, height - topY);
    final effectiveShoulderRadius = _smallestPositive([
      shoulderRadius,
      availableHeight,
      width / 6,
    ]);
    final maxButtonBackgroundRadius = math.max(
      0.0,
      centerX - effectiveShoulderRadius * 2,
    );
    final buttonBackgroundRadius = math.min(
      buttonRadius * _buttonBackgroundScale,
      maxButtonBackgroundRadius,
    );

    return Path()
      ..moveTo(0, topY)
      ..lineTo(0, height)
      ..lineTo(width, height)
      ..lineTo(width, topY)
      ..arcToPoint(
        Offset(width - effectiveShoulderRadius, topY + effectiveShoulderRadius),
        radius: Radius.circular(effectiveShoulderRadius),
      )
      ..lineTo(
        centerX + buttonBackgroundRadius + effectiveShoulderRadius,
        topY + effectiveShoulderRadius,
      )
      ..arcToPoint(
        Offset(centerX + buttonBackgroundRadius, topY),
        radius: Radius.circular(effectiveShoulderRadius),
      )
      ..arcToPoint(
        Offset(centerX - buttonBackgroundRadius, topY),
        radius: Radius.circular(buttonBackgroundRadius),
        clockwise: false,
      )
      ..arcToPoint(
        Offset(
          centerX - buttonBackgroundRadius - effectiveShoulderRadius,
          topY + effectiveShoulderRadius,
        ),
        radius: Radius.circular(effectiveShoulderRadius),
      )
      ..lineTo(effectiveShoulderRadius, topY + effectiveShoulderRadius)
      ..arcToPoint(
        Offset(0, topY),
        radius: Radius.circular(effectiveShoulderRadius),
      )
      ..close();
  }

  double _smallestPositive(List<double> values) {
    return values.fold<double>(
      double.infinity,
      (result, value) => math.min(result, math.max(0.0, value)),
    );
  }

  @override
  bool shouldRepaint(covariant RecordPanelShapePainter oldDelegate) {
    return color != oldDelegate.color ||
        buttonCenterY != oldDelegate.buttonCenterY ||
        buttonRadius != oldDelegate.buttonRadius ||
        shoulderRadius != oldDelegate.shoulderRadius;
  }
}
