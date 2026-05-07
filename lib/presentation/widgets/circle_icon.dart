import 'package:flutter/widgets.dart';

import 'package:voice_memos/presentation/presentation.dart';

class CircleIcon extends StatelessWidget {
  final Color background;
  final Color foreground;
  final IconData icon;
  final EdgeInsets padding;
  final double size;

  const CircleIcon({
    required this.icon,
    this.background = VoiceMemosColors.faint,
    this.foreground = VoiceMemosColors.textDark,
    this.padding = const EdgeInsets.all(10),
    this.size = 25,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: background,
      ),
      child: Center(
        child: Icon(
          icon,
          size: size,
          color: foreground,
        ),
      ),
    );
  }
}
