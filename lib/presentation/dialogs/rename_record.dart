import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:voice_memos/domain/domain.dart';
import 'package:voice_memos/presentation/presentation.dart';

class RenameRecordDialog extends StatefulWidget {
  final Record record;
  const RenameRecordDialog({required this.record, super.key});

  static Future<String?> show(BuildContext context, Record record) {
    return BaseDialog.show<String>(
      context: context,
      builder: (context) {
        return RenameRecordDialog(record: record);
      },
    );
  }

  @override
  State<RenameRecordDialog> createState() => _RenameRecordDialogState();
}

class _RenameRecordDialogState extends State<RenameRecordDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.record.name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      child: DialogContent(
        icon: CircleIcon(
          background: VoiceMemosColors.black,
          foreground: VoiceMemosColors.white,
          icon: CupertinoIcons.pen,
          size: 30,
        ),
        title: Text('RENAME MEMO'),
        child: Column(
          children: [
            Text('Give it a name you\'ll remember.'),
            const Gap(16),
            TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.sentences,
              autofocus: true,
              maxLength: 40,
              buildCounter: textFieldCounterBuilder,
              decoration: InputDecoration(hintText: 'Memo name'),
            ),
            const Gap(16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('CANCEL'),
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: _controller,
                    builder: (context, value, child) {
                      final name = value.text.trim();
                      return FilledButton(
                        onPressed:
                            name.isEmpty
                                ? null
                                : () {
                                  Navigator.of(context).pop(name);
                                },
                        child: child,
                      );
                    },
                    child: Text('SAVE'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
