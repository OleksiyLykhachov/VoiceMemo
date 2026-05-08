import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import 'package:voice_memos/domain/domain.dart';
import 'package:voice_memos/presentation/presentation.dart';
import 'package:voice_memos/utils/utils.dart';

class RecordOptionsHeader extends StatelessWidget {
  final Record record;

  const RecordOptionsHeader({
    required this.record,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d');

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                record.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: VoiceMemosTextStyles.displayLarge,
              ),
              const Gap(6),
              Text(
                '${record.duration.getFormattedString()}  ·  ${dateFormat.format(record.createdAt)}'
                    .toUpperCase(),
                style: VoiceMemosTextStyles.labelSmall.copyWith(
                  color: VoiceMemosColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
