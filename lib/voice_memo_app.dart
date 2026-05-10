import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:voice_memos/presentation/presentation.dart';

class VoiceMemoApp extends StatelessWidget {
  const VoiceMemoApp({super.key});

  static const _systemUiOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemStatusBarContrastEnforced: false,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarContrastEnforced: false,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: themeData(),
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: _systemUiOverlayStyle,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const HomePage(),
    );
  }
}
