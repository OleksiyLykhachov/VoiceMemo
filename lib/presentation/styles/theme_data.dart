import 'package:flutter/material.dart';

import 'voice_memos_colors.dart';

const textFieldTextStyle = TextStyle(
  color: VoiceMemosColors.textDark,
  fontSize: 16,
  fontWeight: FontWeight.w600,
);

ThemeData themeData() {
  const buttonTextStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w700);

  const buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );
  const buttonPadding = EdgeInsets.all(16);

  return ThemeData(
    fontFamily: 'SF Pro Display',
    brightness: Brightness.light,
    disabledColor: VoiceMemosColors.grey,
    chipTheme: ChipThemeData(
      backgroundColor: VoiceMemosColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadiusGeometry.all(
          Radius.circular(25),
        ),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: textFieldTextStyle,
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
        textStyle: buttonTextStyle,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: VoiceMemosColors.black,
        padding: buttonPadding,
        side: const BorderSide(width: 2),
        shape: buttonShape,
        textStyle: buttonTextStyle,
      ),
    ),
  );
}

InputDecorationTheme inputDecorationTheme() {
  const borderSide = BorderSide(
    color: VoiceMemosColors.black,
    width: 2,
  );

  final borderRadius = BorderRadius.circular(12);

  return InputDecorationTheme(
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    ),
    hintStyle: textFieldTextStyle.copyWith(
      color: VoiceMemosColors.textSecondary,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: borderSide.copyWith(
        color: VoiceMemosColors.grey,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: borderSide,
    ),
  );
}
