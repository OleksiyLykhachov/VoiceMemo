import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:voice_memos/domain/domain.dart';
import 'package:voice_memos/presentation/presentation.dart';

class DeleteRecordDialog extends StatelessWidget {
  final Record record;

  const DeleteRecordDialog({
    required this.record,
    super.key,
  });

  static Future<bool> show(BuildContext context, Record record) async {
    final confirmed = await BaseDialog.show<bool>(
      context: context,
      builder: (context) {
        return DeleteRecordDialog(record: record);
      },
    );

    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      child: DialogContent(
        icon: CircleIcon(
          icon: CupertinoIcons.delete,
          background: VoiceMemosColors.red,
          foreground: VoiceMemosColors.white,
        ),
        title: Text('DELETE THIS\nMEMO?'),
        child: Column(
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'This will permanently remove'),
                  TextSpan(
                    text: ' "${record.name}" ',
                    style: TextStyle(
                      color: VoiceMemosColors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(text: 'from your library. This can\'tbe undone.'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: VoiceMemosColors.red,
                ),
                child: Text('DELETE MEMO'),
              ),
            ),
            const Gap(12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text('KEEP IT'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
