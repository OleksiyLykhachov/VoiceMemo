import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:voice_memos/domain/domain.dart';
import 'package:voice_memos/presentation/home/bloc/bloc.dart';

class _MockRecordsRepository extends Mock implements RecordsRepository {}

class _FakeRecord extends Fake implements Record {}

void main() {
  late _MockRecordsRepository repository;

  final existingRecord = Record(
    id: 1,
    name: 'Old name',
    createdAt: DateTime(2026, 1, 1),
    filePath: '/tmp/old.m4a',
    duration: 1_000,
  );
  final secondRecord = Record(
    id: 2,
    name: 'Second',
    createdAt: DateTime(2026, 1, 2),
    filePath: '/tmp/second.m4a',
    duration: 2_000,
  );

  setUpAll(() {
    registerFallbackValue(_FakeRecord());
  });

  setUp(() {
    repository = _MockRecordsRepository();
  });

  group('RecordsBloc', () {
    test('has an empty initial state', () async {
      final bloc = RecordsBloc(repository: repository);

      expect(bloc.state, const RecordsState());

      await bloc.close();
    });

    blocTest<RecordsBloc, RecordsState>(
      'emits loading states and loaded records when load succeeds',
      setUp: () {
        when(
          () => repository.getRecords(),
        ).thenAnswer((_) async => [existingRecord, secondRecord]);
      },
      build: () => RecordsBloc(repository: repository),
      act: (bloc) => bloc.add(const RecordsEvent.load()),
      expect: () => [
        const RecordsState(loading: true),
        RecordsState(records: [existingRecord, secondRecord], loading: true),
        RecordsState(records: [existingRecord, secondRecord]),
      ],
      verify: (_) {
        verify(() => repository.getRecords()).called(1);
      },
    );

    test('emits failure notification when load fails', () async {
      when(() => repository.getRecords()).thenThrow(Exception('load failed'));

      final bloc = RecordsBloc(repository: repository);
      final notificationExpectation = expectLater(
        bloc.notificationStream,
        emits(
          const RecordsNotification.failure('Something went wrong'),
        ),
      );

      bloc.add(const RecordsEvent.load());

      await notificationExpectation;
      expect(bloc.state, const RecordsState());
      await bloc.close();
    });

    blocTest<RecordsBloc, RecordsState>(
      'prepends saved record when save succeeds',
      setUp: () {
        when(() => repository.save(any())).thenAnswer(
          (_) async => Record(
            id: 3,
            name: 'New record',
            createdAt: DateTime(2026, 1, 3),
            filePath: '/tmp/new.m4a',
            duration: 3_000,
          ),
        );
      },
      build: () => RecordsBloc(repository: repository),
      seed: () => RecordsState(records: [existingRecord]),
      act: (bloc) => bloc.add(
        RecordsEvent.save(
          file: File('/tmp/new.m4a'),
          name: 'New record',
          duration: const Duration(seconds: 3),
        ),
      ),
      expect: () => [
        RecordsState(
          records: [
            Record(
              id: 3,
              name: 'New record',
              createdAt: DateTime(2026, 1, 3),
              filePath: '/tmp/new.m4a',
              duration: 3_000,
            ),
            existingRecord,
          ],
        ),
      ],
      verify: (_) {
        verify(() => repository.save(any())).called(1);
      },
    );

    test('emits failure notification when save fails', () async {
      when(() => repository.save(any())).thenThrow(Exception('save failed'));

      final bloc = RecordsBloc(repository: repository);
      final notificationExpectation = expectLater(
        bloc.notificationStream,
        emits(
          const RecordsNotification.failure('Something went wrong'),
        ),
      );

      bloc.add(
        RecordsEvent.save(
          file: File('/tmp/new.m4a'),
          name: 'New record',
          duration: const Duration(seconds: 3),
        ),
      );

      await notificationExpectation;
      expect(bloc.state, const RecordsState());
      await bloc.close();
    });

    blocTest<RecordsBloc, RecordsState>(
      'updates record name optimistically when rename succeeds',
      setUp: () {
        when(
          () => repository.save(any()),
        ).thenAnswer((_) async => existingRecord);
      },
      build: () => RecordsBloc(repository: repository),
      seed: () => RecordsState(records: [existingRecord, secondRecord]),
      act: (bloc) => bloc.add(
        const RecordsEvent.rename(id: 1, name: 'Renamed'),
      ),
      expect: () => [
        RecordsState(
          records: [
            Record(
              id: 1,
              name: 'Renamed',
              createdAt: DateTime(2026, 1, 1),
              filePath: '/tmp/old.m4a',
              duration: 1_000,
            ),
            secondRecord,
          ],
        ),
      ],
      verify: (_) {
        verify(() => repository.save(any())).called(1);
      },
    );

    blocTest<RecordsBloc, RecordsState>(
      'rolls back optimistic rename when repository save fails',
      setUp: () {
        when(
          () => repository.save(any()),
        ).thenThrow(Exception('rename failed'));
      },
      build: () => RecordsBloc(repository: repository),
      seed: () => RecordsState(records: [existingRecord, secondRecord]),
      act: (bloc) => bloc.add(
        const RecordsEvent.rename(id: 1, name: 'Renamed'),
      ),
      expect: () => [
        RecordsState(
          records: [
            Record(
              id: 1,
              name: 'Renamed',
              createdAt: DateTime(2026, 1, 1),
              filePath: '/tmp/old.m4a',
              duration: 1_000,
            ),
            secondRecord,
          ],
        ),
        RecordsState(records: [existingRecord, secondRecord]),
      ],
    );

    test('emits failure notification when rename fails', () async {
      when(() => repository.save(any())).thenThrow(Exception('rename failed'));

      final bloc = RecordsBloc(repository: repository)
        ..emit(RecordsState(records: [existingRecord]));
      final notificationExpectation = expectLater(
        bloc.notificationStream,
        emits(
          const RecordsNotification.failure('Something went wrong'),
        ),
      );

      bloc.add(const RecordsEvent.rename(id: 1, name: 'Renamed'));

      await notificationExpectation;
      await bloc.close();
    });

    blocTest<RecordsBloc, RecordsState>(
      'removes record optimistically when delete succeeds',
      setUp: () {
        when(() => repository.delete(1)).thenAnswer((_) async {});
      },
      build: () => RecordsBloc(repository: repository),
      seed: () => RecordsState(records: [existingRecord, secondRecord]),
      act: (bloc) => bloc.add(const RecordsEvent.delete(1)),
      expect: () => [
        RecordsState(records: [secondRecord]),
      ],
      verify: (_) {
        verify(() => repository.delete(1)).called(1);
      },
    );

    blocTest<RecordsBloc, RecordsState>(
      'rolls back optimistic delete when repository delete fails',
      setUp: () {
        when(() => repository.delete(1)).thenThrow(Exception('delete failed'));
      },
      build: () => RecordsBloc(repository: repository),
      seed: () => RecordsState(records: [existingRecord, secondRecord]),
      act: (bloc) => bloc.add(const RecordsEvent.delete(1)),
      expect: () => [
        RecordsState(records: [secondRecord]),
        RecordsState(records: [existingRecord, secondRecord]),
      ],
    );

    test('emits failure notification when delete fails', () async {
      when(() => repository.delete(1)).thenThrow(Exception('delete failed'));

      final bloc = RecordsBloc(repository: repository)
        ..emit(RecordsState(records: [existingRecord]));
      final notificationExpectation = expectLater(
        bloc.notificationStream,
        emits(
          const RecordsNotification.failure('Something went wrong'),
        ),
      );

      bloc.add(const RecordsEvent.delete(1));

      await notificationExpectation;
      await bloc.close();
    });
  });
}
