import 'package:flutter/material.dart';

class HomeBackground extends StatelessWidget {
  final Widget child;

  const HomeBackground({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Text(
            'VOICE\nMEMOS',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 85,
              fontWeight: FontWeight.w800,
              height: 75 / 85,
              letterSpacing: -5,
            ),
          ),
        ),
        Expanded(
          child: Transform.translate(
            offset: Offset(0, -45),
            child: child,
          ),
        ),
      ],
    );
  }
}
