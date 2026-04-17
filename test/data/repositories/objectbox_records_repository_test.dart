import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:voice_memos/data/repositories/objectbox_records_repository.dart';
import 'package:voice_memos/domain/domain.dart';
import 'package:voice_memos/objectbox.g.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Directory? tempDirectory;
  Store? store;
  late ObjectBoxRecordsRepository repository;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'objectbox_records_repository_test_',
    );
    store = await openStore(directory: tempDirectory!.path);
    repository = ObjectBoxRecordsRepository(store!);
  });

  tearDown(() async {
    store?.close();
    store = null;

    if (tempDirectory != null && await tempDirectory!.exists()) {
      await tempDirectory!.delete(recursive: true);
    }
    tempDirectory = null;
  });

  group('ObjectBoxRecordsRepository', () {
    test(
      'save persists records and getRecords returns them sorted by date desc',
      () async {
        final olderRecord = _record(
          id: 0,
          name: 'older',
          createdAt: DateTime(2024, 1, 1),
        );
        final newerRecord = _record(
          id: 0,
          name: 'newer',
          createdAt: DateTime(2024, 1, 2),
        );

        await repository.save(olderRecord);
        await repository.save(newerRecord);

        final records = await repository.getRecords();

        expect(records, hasLength(2));
        expect(records.map((record) => record.name).toList(), [
          'newer',
          'older',
        ]);
        expect(
          records.map((record) => record.createdAt).toList(),
          [DateTime(2024, 1, 2), DateTime(2024, 1, 1)],
        );
        expect(records.every((record) => record.id > 0), isTrue);
      },
    );

    test(
      'delete removes a record by id',
      () async {
        final firstRecord = _record(
          id: 0,
          name: 'first',
          createdAt: DateTime(2024, 1, 1),
        );
        final secondRecord = _record(
          id: 0,
          name: 'second',
          createdAt: DateTime(2024, 1, 2),
        );

        await repository.save(firstRecord);
        await repository.save(secondRecord);

        final savedRecords = await repository.getRecords();
        final firstSavedRecord = savedRecords.singleWhere(
          (record) => record.name == firstRecord.name,
        );

        await repository.delete(firstSavedRecord.id);

        final records = await repository.getRecords();

        expect(records, hasLength(1));
        expect(records.single.name, secondRecord.name);
      },
    );

    test(
      'delete ignores missing ids',
      () async {
        final record = _record(
          id: 0,
          name: 'kept',
          createdAt: DateTime(2024, 1, 1),
        );

        await repository.save(record);

        await repository.delete(999);

        final records = await repository.getRecords();
        expect(records, hasLength(1));
        expect(records.single.name, record.name);
      },
    );

    test(
      'getRecordsStream emits current records immediately and updates on changes',
      () async {
        final olderRecord = _record(
          id: 0,
          name: 'older',
          createdAt: DateTime(2024, 1, 1),
        );
        final newerRecord = _record(
          id: 0,
          name: 'newer',
          createdAt: DateTime(2024, 1, 2),
        );

        final expectation = expectLater(
          repository.getRecordsStream().take(2),
          emitsInOrder([
            <Record>[],
            predicate<List<Record>>(
              (records) =>
                  records.length == 2 &&
                  records[0].name == newerRecord.name &&
                  records[1].name == olderRecord.name &&
                  records[0].createdAt == newerRecord.createdAt &&
                  records[1].createdAt == olderRecord.createdAt,
            ),
          ]),
        );

        await Future<void>.delayed(Duration.zero);
        await repository.save(newerRecord);
        await repository.save(olderRecord);

        await expectation;
      },
    );
  });
}

Record _record({
  required int id,
  required String name,
  required DateTime createdAt,
}) {
  return Record(
    id: id,
    name: name,
    createdAt: createdAt,
    filePath: '/tmp/$name.m4a',
    duration: 42,
  );
}
