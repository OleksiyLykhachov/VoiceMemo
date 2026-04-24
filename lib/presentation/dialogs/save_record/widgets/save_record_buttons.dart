import 'package:flutter/material.dart';

import 'package:gap/gap.dart';

class SaveRecordButtons extends StatelessWidget {
  final VoidCallback onDiscard;
  final VoidCallback onSave;

  const SaveRecordButtons({
    super.key,
    required this.onDiscard,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: OutlinedButton(
            onPressed: onDiscard,
            child: const Text('DISCARD'),
          ),
        ),
        const Gap(8),
        Expanded(
          flex: 3,
          child: FilledButton(
            onPressed: onSave,
            child: const Text('SAVE MEMO'),
          ),
        ),
      ],
    );
  }
}
