import 'package:flutter/material.dart';

class NameSuggestionChips extends StatelessWidget {
  final ValueChanged<String> onSelected;
  
  const NameSuggestionChips({
    required this.onSelected,
    super.key,
  });

  static const _suggestions = [
    'Idea',
    'Meeting',
    'Note to self',
    'Lyric',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      children: [
        for (final suggestion in _suggestions)
          ActionChip(
            onPressed: () => onSelected(suggestion),
            label: Text(suggestion),
          ),
      ],
    );
  }
}
