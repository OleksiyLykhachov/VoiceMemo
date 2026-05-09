import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:voice_memos/domain/domain.dart';
import 'package:voice_memos/presentation/home/bloc/bloc.dart';
import 'package:voice_memos/utils/player_service/player_service.dart' as audio;

class _MockPlayerService extends Mock implements audio.PlayerService {}

class _FakeRecord extends Fake implements Record {}

void main() {
  late _MockPlayerService playerService;

  final record = Record(
    id: 1,
    name: 'Memo',
    createdAt: DateTime(2026, 1, 1),
    filePath: '/tmp/memo.m4a',
    durationMs: 30_000,
  );

  setUpAll(() {
    registerFallbackValue(_FakeRecord());
    registerFallbackValue(Duration.zero);
    registerFallbackValue(File('/tmp/fallback.m4a'));
  });

  setUp(() {
    playerService = _MockPlayerService();
    when(
      () => playerService.stateStream,
    ).thenAnswer((_) => const Stream<audio.PlayerState>.empty());
    when(() => playerService.dispose()).thenAnswer((_) async {});
    when(() => playerService.pause()).thenAnswer((_) async {});
    when(() => playerService.play()).thenAnswer((_) async {});
    when(() => playerService.seek(any())).thenAnswer((_) async {});
    when(() => playerService.position).thenReturn(Duration.zero);
  });

  group('PlayerBloc', () {
    test('emits failure notification when opening a recording fails', () async {
      when(() => playerService.init(any())).thenThrow(Exception('open failed'));

      final bloc = PlayerBloc(playerService: playerService);
      final notificationExpectation = expectLater(
        bloc.notificationStream,
        emits(
          const PlayerNotification.failure(
            'Could not open the recording. Please try again.',
          ),
        ),
      );

      bloc.add(PlayerEvent.setRecord(record));

      await notificationExpectation;
      await bloc.close();
    });

    test('emits failure notification when play fails', () async {
      when(() => playerService.play()).thenThrow(Exception('play failed'));

      final bloc = PlayerBloc(playerService: playerService)
        ..emit(PlayerState(record: record));
      final notificationExpectation = expectLater(
        bloc.notificationStream,
        emits(
          const PlayerNotification.failure(
            'Could not play the recording. Please try again.',
          ),
        ),
      );

      bloc.add(const PlayerEvent.togglePlay());

      await notificationExpectation;
      await bloc.close();
    });

    test('emits failure notification when pause fails', () async {
      when(() => playerService.pause()).thenThrow(Exception('pause failed'));

      final bloc = PlayerBloc(playerService: playerService)
        ..emit(PlayerState(record: record, playing: true));
      final notificationExpectation = expectLater(
        bloc.notificationStream,
        emits(
          const PlayerNotification.failure(
            'Could not pause the recording. Please try again.',
          ),
        ),
      );

      bloc.add(const PlayerEvent.togglePlay());

      await notificationExpectation;
      await bloc.close();
    });

    test('emits failure notification when seeking forward fails', () async {
      when(() => playerService.seek(any())).thenThrow(Exception('seek failed'));

      final bloc = PlayerBloc(playerService: playerService)
        ..emit(PlayerState(record: record));
      final notificationExpectation = expectLater(
        bloc.notificationStream,
        emits(
          const PlayerNotification.failure(
            'Could not skip forward. Please try again.',
          ),
        ),
      );

      bloc.add(const PlayerEvent.seekForward(Duration(seconds: 10)));

      await notificationExpectation;
      await bloc.close();
    });

    test('emits failure notification when seeking backward fails', () async {
      when(() => playerService.seek(any())).thenThrow(Exception('seek failed'));
      when(() => playerService.position).thenReturn(const Duration(seconds: 5));

      final bloc = PlayerBloc(playerService: playerService)
        ..emit(PlayerState(record: record));
      final notificationExpectation = expectLater(
        bloc.notificationStream,
        emits(
          const PlayerNotification.failure(
            'Could not skip backward. Please try again.',
          ),
        ),
      );

      bloc.add(const PlayerEvent.seekBackward(Duration(seconds: 10)));

      await notificationExpectation;
      await bloc.close();
    });
  });
}
