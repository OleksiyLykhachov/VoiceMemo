import 'dart:async';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart' as ja;

import '../combine_latest_transformer.dart';

abstract interface class PlayerService {
  Future<void> init(File file);
  Future<void> seek(Duration position);
  Future<void> seekBy(Duration duration);
  Future<void> play();
  Future<void> pause();

  Future<void> dispose();

  Stream<PlayerState> get stateStream;
  PlayerState get playerState;
  Duration? get duration;
  Duration get position;
}

@Injectable(as: PlayerService)
class PlayerServiceImpl implements PlayerService {
  final ja.AudioPlayer _player;

  late final StreamSubscription<ja.ProcessingState> _stateSub;

  PlayerServiceImpl({
    required ja.AudioPlayer player,
  }) : _player = player {
    _stateSub = _player.processingStateStream.listen((state) {
      if (state == ja.ProcessingState.completed) {
        _player.stop();
        _player.seek(Duration.zero);
      }
    });
  }

  @override
  Future<void> dispose() {
    return Future.wait([
      _stateSub.cancel(),
      _player.dispose(),
    ]);
  }

  Stream<Duration> get positionStream {
    return _player.positionStream;
  }

  @override
  Future<void> init(File file) async {
    if (!await file.exists()) {
      throw ArgumentError.value(
        file.path,
        'file.path',
        'Audio file does not exist',
      );
    }

    await _player.setFilePath(file.path);
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

  @override
  PlayerState get playerState {
    return PlayerState(
      playing: _player.playing,
      position: _player.position,
    );
  }

  @override
  Stream<PlayerState> get stateStream {
    return _player.positionStream.combineLatestWith(
      _player.playerStateStream,
      (position, playerState) => PlayerState(
        playing: playerState.playing,
        position: position,
      ),
    );
  }
}

class PlayerState {
  final bool playing;
  final Duration position;

  PlayerState({
    required this.playing,
    required this.position,
  });
}
