import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:voice_memos/presentation/home/bloc/recorder_bloc/recorder_bloc.dart';
import 'package:voice_memos/utils/recorder_service/recorder_serivce.dart';

class _MockRecorderService extends Mock implements RecorderService {}

void main() {
  late _MockRecorderService recorderService;

  setUp(() {
    recorderService = _MockRecorderService();
    when(() => recorderService.dispose()).thenAnswer((_) async {});
  });

  group('RecorderBloc', () {
    test('has an empty initial state', () async {
      final bloc = RecorderBloc(recorderService: recorderService);

      expect(bloc.state, const RecorderState());

      await bloc.close();
    });

    blocTest<RecorderBloc, RecorderState>(
      'emits nothing when start is added while already recording',
      build: () => RecorderBloc(recorderService: recorderService),
      seed: () => const RecorderState(recording: true),
      act: (bloc) => bloc.add(const RecorderEvent.start()),
      expect: () => <RecorderState>[],
      verify: (_) {
        verifyNever(() => recorderService.resolvePermission());
        verifyNever(() => recorderService.requestPermission());
        verifyNever(() => recorderService.start());
      },
    );

    blocTest<RecorderBloc, RecorderState>(
      'requests permission before starting when initial permission check fails',
      setUp: () {
        final amplitudeStream = Stream<AmplitudeData>.value(
          const AmplitudeData(current: 0.5, max: 1),
        );
        when(
          () => recorderService.resolvePermission(),
        ).thenAnswer((_) async => false);
        when(
          () => recorderService.requestPermission(),
        ).thenAnswer((_) async => true);
        when(() => recorderService.start()).thenAnswer((_) async {});
        when(
          () => recorderService.getAmplitudeStream(),
        ).thenAnswer((_) => amplitudeStream);
      },
      build: () => RecorderBloc(recorderService: recorderService),
      act: (bloc) => bloc.add(const RecorderEvent.start()),
      expect: () => [
        const RecorderState(show: true),
        isA<RecorderState>()
            .having((state) => state.show, 'show', true)
            .having((state) => state.recording, 'recording', true)
            .having((state) => state.amplitudeStream, 'amplitudeStream', isNotNull)
            .having((state) => state.startedAt, 'startedAt', isNotNull),
      ],
      verify: (_) {
        verify(() => recorderService.resolvePermission()).called(1);
        verify(() => recorderService.requestPermission()).called(1);
        verify(() => recorderService.start()).called(1);
        verify(() => recorderService.getAmplitudeStream()).called(1);
      },
    );

    blocTest<RecorderBloc, RecorderState>(
      'emits overlay state and recording state when recording starts successfully',
      setUp: () {
        final amplitudeStream = Stream<AmplitudeData>.value(
          const AmplitudeData(current: 0.5, max: 1),
        );
        when(
          () => recorderService.resolvePermission(),
        ).thenAnswer((_) async => true);
        when(() => recorderService.start()).thenAnswer((_) async {});
        when(
          () => recorderService.getAmplitudeStream(),
        ).thenAnswer((_) => amplitudeStream);
      },
      build: () => RecorderBloc(recorderService: recorderService),
      act: (bloc) => bloc.add(const RecorderEvent.start()),
      expect: () => [
        const RecorderState(show: true),
        isA<RecorderState>()
            .having((state) => state.show, 'show', true)
            .having((state) => state.recording, 'recording', true)
            .having((state) => state.amplitudeStream, 'amplitudeStream', isNotNull)
            .having((state) => state.startedAt, 'startedAt', isNotNull),
      ],
      verify: (_) {
        verify(() => recorderService.resolvePermission()).called(1);
        verify(() => recorderService.start()).called(1);
        verify(() => recorderService.getAmplitudeStream()).called(1);
        verifyNever(() => recorderService.requestPermission());
      },
    );

    blocTest<RecorderBloc, RecorderState>(
      'emits idle state when recording stops',
      setUp: () {
        when(() => recorderService.stop()).thenAnswer(
          (_) async => AudioRecording(
            file: File('/tmp/recording.pcm'),
            duration: const Duration(seconds: 3),
          ),
        );
      },
      build: () => RecorderBloc(recorderService: recorderService),
      seed: () => RecorderState(
        recording: true,
        show: true,
        amplitudeStream: Stream<AmplitudeData>.empty(),
        startedAt: DateTime(2026, 1, 1),
      ),
      act: (bloc) => bloc.add(const RecorderEvent.stop()),
      expect: () => const [
        RecorderState(),
      ],
      verify: (_) {
        verify(() => recorderService.stop()).called(1);
      },
    );

    test('emits recorded notification when recording stops', () async {
      final file = File('/tmp/recording.pcm');
      when(() => recorderService.stop()).thenAnswer(
        (_) async => AudioRecording(
          file: file,
          duration: const Duration(seconds: 3),
        ),
      );

      final bloc = RecorderBloc(recorderService: recorderService);
      bloc.emit(
        RecorderState(
          recording: true,
          show: true,
          amplitudeStream: Stream<AmplitudeData>.empty(),
          startedAt: DateTime(2026, 1, 1),
        ),
      );

      final notificationExpectation = expectLater(
        bloc.notificationStream,
        emits(
          isA<RecorderNotification>().having(
            (notification) => notification.map(
              recorded: (recorded) => recorded.file,
              failure: (_) => null,
            ),
            'file',
            file,
          ).having(
            (notification) => notification.map(
              recorded: (recorded) => recorded.duration,
              failure: (_) => null,
            ),
            'duration',
            const Duration(seconds: 3),
          ),
        ),
      );

      bloc.add(const RecorderEvent.stop());

      await notificationExpectation;
      await bloc.close();
    });
  });
}
