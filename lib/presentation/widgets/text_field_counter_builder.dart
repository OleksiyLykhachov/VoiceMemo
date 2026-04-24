import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:voice_memos/presentation/styles/voice_memos_colors.dart';

Widget? textFieldCounterBuilder(
  BuildContext context, {
  required int currentLength,
  required bool isFocused,
  required int? maxLength,
}) {
  return Container(
    alignment: Alignment.centerRight,
    transform: Matrix4.translationValues(20, 0, 0),
    child: Text(
      maxLength == null ? '$currentLength' : '$currentLength/$maxLength',
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: VoiceMemosColors.black,
      ),
    ),
  );
}
