import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:voice_memos/domain/domain.dart';
import 'package:voice_memos/presentation/presentation.dart';

import 'widgets/record_option_item.dart';
import 'widgets/record_options_header.dart';

enum RecordOption { delete, rename }

class RecordOptionsBottomSheet extends StatelessWidget {
  final Record record;

  const RecordOptionsBottomSheet({required this.record, super.key});

  static Future<RecordOption?> show(BuildContext context, Record record) {
    return BaseBottomSheet.show(
      context: context,
      builder: (context) {
        return RecordOptionsBottomSheet(record: record);
      },
    );
  }

  void _select(BuildContext context, RecordOption option) {
    Navigator.of(context).pop(option);
  }

  @override
  Widget build(BuildContext context) {
    return BaseBottomSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: RecordOptionsHeader(record: record),
          ),
          Divider(color: VoiceMemosColors.border, height: 32, thickness: 1),
          RecordOptionItem(
            onTap: () => _select(context, RecordOption.rename),
            colors: RecordOptionColors.standard(),
            icon: CupertinoIcons.pen,
            title: Text('Rename'),
            subtitle: Text('Change the title of this memo'),
          ),
          const Gap(12),
          RecordOptionItem(
            onTap: () => _select(context, RecordOption.delete),
            colors: RecordOptionColors.destructive(),
            icon: CupertinoIcons.delete,
            title: Text('Delete'),
            subtitle: Text('Permanently remove this memo'),
          ),
          const Gap(18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('CANCEL'),
            ),
          ),
        ],
      ),
    );
  }
}
