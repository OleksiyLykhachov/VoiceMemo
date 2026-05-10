import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:voice_memos/utils/utils.dart';

import 'voice_memo_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));

  final getIt = await configureDependencies();

  runApp(GetItProvider(getIt: getIt, child: const VoiceMemoApp()));
}
