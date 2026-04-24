import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart';

abstract interface class PlayerService {
  Future<void> init(File file);
  Future<void> seek(Duration position);
  Future<void> seekBy(Duration duration);
  Future<void> play();
  Future<void> pause();

  Future<void> dispose();
  Stream<Duration> get positionStream;
  Duration? get duration;
  Duration get position;
}

@Injectable(as: PlayerService)
class PlayerServiceImpl implements PlayerService {
  final AudioPlayer _player;

  const PlayerServiceImpl({
    required AudioPlayer player,
  }) : _player = player;

  @override
  Future<void> dispose() {
    return _player.dispose();
  }

  @override
  Stream<Duration> get positionStream {
    return _player.positionStream;
  }

  @override
  Future<void> init(File file) {
    return _player.setUrl('file://${file.path}');
  }

  @override
  Future<void> pause() {
    return _player.pause();
  }

  @override
  Future<void> play() {
    return _player.play();
  }

  @override
  Future<void> seek(Duration position) {
    return _player.seek(position);
  }

  @override
  Future<void> seekBy(Duration duration) {
    return seek(_player.position + duration);
  }

  @override
  Duration? get duration => _player.duration;

  @override
  Duration get position => _player.position;
}
