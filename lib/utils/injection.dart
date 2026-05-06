import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';
import 'package:voice_memos/utils/utils.dart';

import 'injection.config.dart';

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<GetIt> configureDependencies() async {
  final getIt = GetIt.instance;

  return getIt.init();
}

@module
abstract class RegisterModule {
  AudioRecorder get recorder => AudioRecorder();
  AudioPlayer get player => AudioPlayer();

  @preResolve
  Future<RecordsPathUtil> get recordsPathUtil {
    return RecordsPathUtil.create();
  }
}
