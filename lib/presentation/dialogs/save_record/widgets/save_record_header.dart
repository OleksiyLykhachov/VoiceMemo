import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';

import 'package:voice_memos/presentation/presentation.dart';
import 'package:voice_memos/utils/utils.dart';

class SaveRecordHeader extends StatelessWidget {
  final Duration duration;

  const SaveRecordHeader({required this.duration, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: VoiceMemosColors.red,
              ),
            ),
            const Gap(8),
            Text(
              'RECORDING CAPTURED  ·  ${duration.getFormattedString()}',
              style: VoiceMemosTextStyles.labelSmall.copyWith(
                color: VoiceMemosColors.textSecondary,
              ),
            ),
          ],
        ),
        const Gap(8),
        Text('NAME YOUR\nMEMO', style: VoiceMemosTextStyles.displayLarge),
      ],
    );
  }
}
