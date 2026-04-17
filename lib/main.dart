import 'package:flutter/material.dart';
import 'package:voice_memos/utils/utils.dart';

import 'voice_memo_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final getIt = await configureDependencies();

  runApp(
    GetItProvider(
      getIt: getIt,
      child: const VoiceMemoApp(),
    ),
  );
}
