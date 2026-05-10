import 'package:flutter/material.dart';

import 'package:voice_memos/presentation/presentation.dart';

class RecordTitle extends StatelessWidget {
  final String text;
  const RecordTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      _preferBalancedWrap(text),
      textAlign: TextAlign.center,
      maxLines: 2,
      style: VoiceMemosTextStyles.titleLarge.copyWith(
        height: 20 / 21,
      ),
    );
  }
}

String _preferBalancedWrap(String text) {
  final normalizedText = text.trim().replaceAll(RegExp(r'\s+'), ' ');

  if (normalizedText.length > 40) {
    return text;
  }

  final words = normalizedText.split(' ');

  if (words.length < 2) {
    return text;
  }

  ({int index, int score})? bestWrap;

  for (var index = 1; index < words.length; index++) {
    final firstLine = words.take(index).join(' ');
    final secondLine = words.skip(index).join(' ');

    if (firstLine.length < 4 || secondLine.length < 4) {
      continue;
    }

    final leavesSingleWordSecondLine =
        words.length > 2 && index == words.length - 1;
    final score =
        (firstLine.length - secondLine.length).abs() +
        (leavesSingleWordSecondLine ? 8 : 0);

    if (bestWrap == null || score < bestWrap.score) {
      bestWrap = (index: index, score: score);
    }
  }

  if (bestWrap == null) {
    return text;
  }

  return [
    words.take(bestWrap.index).join(' '),
    words.skip(bestWrap.index).join(' '),
  ].join('\n');
}
