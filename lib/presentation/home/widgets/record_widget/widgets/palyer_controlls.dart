import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:voice_memos/presentation/presentation.dart';

class PlayerControlls extends StatelessWidget {
  final VoidCallback onTogglePlay;
  final ValueChanged<Duration> onForward;
  final ValueChanged<Duration> onBackward;
  final bool playing;

  const PlayerControlls({
    required this.onTogglePlay,
    required this.onForward,
    required this.onBackward,
    required this.playing,
    super.key,
  });

  static const _duration = Duration(seconds: 10);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: _IconButton(
            onTap: () => onBackward(_duration),
            path: Assets.backward10,
          ),
        ),
        TappableArea(
          child: SizedBox.square(
            dimension: 80,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: VoiceMemosColors.black,
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                size: 35,
                color: VoiceMemosColors.white,
              ),
            ),
          ),
        ),
        Expanded(
          child: _IconButton(
            onTap: () => onForward(_duration),
            path: Assets.forward10,
          ),
        ),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  final String path;
  final VoidCallback onTap;

  const _IconButton({
    required this.onTap,
    required this.path,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 35,
      child: TappableArea(
        onTap: onTap,
        child: SvgPicture.asset(path),
      ),
    );
  }
}
