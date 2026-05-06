import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart';

@injectable
class RecordDurationUtil {
  final AudioPlayer _player;

  RecordDurationUtil({required AudioPlayer player}) : _player = player;

  Future<Duration?> getFileDuration(File file) async {
    await _player.setFilePath(file.path);

    final duration = _player.duration;

    await _player.clearAudioSources();

    return duration;
  }
}
