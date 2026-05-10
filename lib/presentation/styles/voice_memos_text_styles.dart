import 'package:flutter/material.dart';

abstract class VoiceMemosTextStyles {
  static const displayHero = TextStyle(
    fontSize: 85,
    fontWeight: FontWeight.w700,
    height: 75 / 85,
    letterSpacing: -5,
  );

  static const displayLarge = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 28 / 30,
  );

  static const headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 38 / 40,
  );

  static const titleLarge = TextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w700,
  );

  static const bodyLarge = TextStyle(fontSize: 16, fontWeight: FontWeight.w500);

  static const bodyMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );

  static const bodySmall = TextStyle(fontSize: 12);

  static const labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  static const labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
  );
}
