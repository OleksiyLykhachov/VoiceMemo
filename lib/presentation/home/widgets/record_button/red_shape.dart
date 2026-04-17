import 'package:flutter/material.dart';
import 'package:voice_memos/presentation/presentation.dart';

class RedShape extends StatelessWidget {
  static const color = VoiceMemosColors.red;
  static const circleMargin = 8.0;
  static const squareMargin = 16.0;
  static const squareRadius = 6.0;

  final bool recording;
  final double size;

  const RedShape({
    required this.recording,
    required this.size,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final circleSize = (size - (circleMargin * 2));
    final squareSize = (size - (squareMargin * 2));

    return Center(
      child: AnimatedContainer(
        duration: Durations.medium4,
        curve: Curves.ease,
        width: recording ? squareSize : circleSize,
        height: recording ? squareSize : circleSize,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(
            recording ? squareRadius : circleSize / 2,
          ),
        ),
      ),
    );
  }
}
