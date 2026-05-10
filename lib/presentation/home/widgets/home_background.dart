import 'package:flutter/material.dart';

import 'package:voice_memos/presentation/presentation.dart';

class HomeBackground extends StatelessWidget {
  final Widget child;

  const HomeBackground({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Text(
            'VOICE\nMEMOS',
            textAlign: TextAlign.center,
            style: VoiceMemosTextStyles.displayHero,
          ),
        ),
        Expanded(
          child: Transform.translate(offset: Offset(0, -45), child: child),
        ),
      ],
    );
  }
}
