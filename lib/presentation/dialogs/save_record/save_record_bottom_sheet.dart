import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:voice_memos/presentation/presentation.dart';

import 'widgets/name_suggestion_chips.dart';
import 'widgets/save_record_buttons.dart';
import 'widgets/save_record_header.dart';

class SaveRecordBottomSheet extends StatefulWidget {
  final Duration duration;

  const SaveRecordBottomSheet({
    super.key,
    required this.duration,
  });

  static Future<String?> show({
    required BuildContext context,
    required Duration duration,
  }) {
    return BaseBottomSheet.show(
      context: context,
      builder: (context) {
        return SaveRecordBottomSheet(duration: duration);
      },
    );
  }

  @override
  State<SaveRecordBottomSheet> createState() => _SaveRecordBottomSheetState();
}

class _SaveRecordBottomSheetState extends State<SaveRecordBottomSheet> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return BaseBottomSheet(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SaveRecordHeader(duration: widget.duration),
            const Gap(16),
            TextField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 40,
              buildCounter: textFieldCounterBuilder,
              decoration: InputDecoration(
                hintText: 'Name your memo',
              ),
            ),
            const Gap(16),
            NameSuggestionChips(
              onSelected: (text) {
                _nameController.text = text;
              },
            ),
            const Gap(16),
            SaveRecordButtons(
              onDiscard: () {
                Navigator.pop(context);
              },
              onSave: () {
                Navigator.pop(context, _nameController.text);
              },
            ),
          ],
        ),
      ),
    );
  }
}
