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
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: VoiceMemosColors.grey,
              ),
            ),
          ],
        ),
        const Gap(16),
        Text(
          'NAME YOUR\nMEMO',
          style: TextStyle(
            fontFamily: 'Bebas Neue',
            fontSize: 40,
            fontWeight: FontWeight.w900,
            height: 35 / 40,
          ),
        ),
      ],
    );
  }
}
