import 'package:flutter/widgets.dart';

import 'package:voice_memos/presentation/presentation.dart';
import 'package:voice_memos/utils/utils.dart';

class RecordDuration extends StatelessWidget {
  final Duration duration;

  const RecordDuration(
    this.duration, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      duration.getFormattedString(),
      style: VoiceMemosTextStyles.labelLarge.copyWith(
        color: VoiceMemosColors.textSecondary,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
