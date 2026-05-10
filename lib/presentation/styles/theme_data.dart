import 'package:flutter/material.dart';

import 'voice_memos_colors.dart';
import 'voice_memos_text_styles.dart';

ThemeData themeData() {
  const buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );
  const buttonPadding = EdgeInsets.all(16);

  return ThemeData(
    fontFamily: 'SF Pro Display',
    brightness: Brightness.light,
    disabledColor: VoiceMemosColors.textSecondary,
    chipTheme: ChipThemeData(
      backgroundColor: VoiceMemosColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadiusGeometry.all(Radius.circular(25)),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: VoiceMemosTextStyles.bodyLarge,
    ).copyWith(
      bodyLarge: VoiceMemosTextStyles.bodyLarge.copyWith(
        color: VoiceMemosColors.textDark,
      ),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: VoiceMemosColors.red,
    ),
    inputDecorationTheme: inputDecorationTheme(),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: VoiceMemosColors.black,
        foregroundColor: VoiceMemosColors.white,
        padding: buttonPadding,
        shape: buttonShape,
        textStyle: VoiceMemosTextStyles.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: VoiceMemosColors.black,
        padding: buttonPadding,
        side: const BorderSide(width: 2),
        shape: buttonShape,
        textStyle: VoiceMemosTextStyles.labelLarge,
      ),
    ),
  );
}

InputDecorationTheme inputDecorationTheme() {
  const borderSide = BorderSide(color: VoiceMemosColors.black, width: 2);

  final borderRadius = BorderRadius.circular(12);

  return InputDecorationTheme(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    hintStyle: VoiceMemosTextStyles.bodyLarge.copyWith(
      color: VoiceMemosColors.textSecondary,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: borderSide.copyWith(color: VoiceMemosColors.textSecondary),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: borderSide,
    ),
  );
}
