import 'package:flutter/material.dart';

class RecordPanelClipper extends CustomClipper<Path> {
  final double buttonRadius;
  
  const RecordPanelClipper({
    required this.buttonRadius,
  });

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    final halfW = w / 2;

    final thirdOfH = h / 3;

    final path = Path()
      ..moveTo(0, thirdOfH)
      ..lineTo(0, h)
      ..lineTo(w, h)
      ..lineTo(w, thirdOfH);

    final sideR = 36.0;

    path.arcToPoint(
      Offset(w - sideR, thirdOfH + sideR),
      radius: Radius.circular(sideR),
      clockwise: true,
    );

    path.lineTo(
      halfW + buttonRadius + sideR,
      thirdOfH + sideR,
    );

    path.arcToPoint(
      Offset(halfW + buttonRadius, thirdOfH),
      radius: Radius.circular(sideR),
      clockwise: true,
    );

    path.arcToPoint(
      Offset(halfW - buttonRadius, thirdOfH),
      radius: Radius.circular(buttonRadius),
      clockwise: false,
    );

    path.arcToPoint(
      Offset(halfW - buttonRadius - sideR, thirdOfH + sideR),
      radius: Radius.circular(sideR),
      clockwise: true,
    );

    path.lineTo(
      sideR,
      thirdOfH + sideR,
    );

    path.arcToPoint(
      Offset(0, thirdOfH),
      radius: Radius.circular(sideR),
      clockwise: true,
    );

    return path;
  }

  @override
  bool shouldReclip(covariant RecordPanelClipper oldClipper) {
    return buttonRadius != oldClipper.buttonRadius;
  }
}
