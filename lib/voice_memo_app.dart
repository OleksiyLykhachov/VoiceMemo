import 'package:flutter/material.dart';

class VoiceMemoApp extends StatelessWidget {
  const VoiceMemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
    );
  }
}
