import 'package:objectbox/objectbox.dart';
import 'package:injectable/injectable.dart' hide Order;

import 'package:voice_memos/domain/domain.dart';
import 'package:voice_memos/objectbox.g.dart' hide Order;

import '../models/record_model.dart';

@Injectable(as: RecordsRepository)
class ObjectBoxRecordsRepository implements RecordsRepository {
  ObjectBoxRecordsRepository(this._store);

  final Store _store;

  Box<RecordModel> get _recordsBox => _store.box<RecordModel>();

  @override
  Future<void> delete(int id) async {
    final query = _recordsBox
        .query(RecordModel_.objectBoxId.equals(id))
        .build();
    final record = query.findFirst();
    query.close();

    if (record != null) {
      _recordsBox.remove(record.objectBoxId);
    }
  }

  @override
  Future<List<Record>> getRecords() async {
    final records = _recordsBox.getAll();
    records.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return records.map((record) => record.toEntity()).toList(growable: false);
  }

  @override
  Future<Record?> getRecordById(int id) async {
    final record = _recordsBox.get(id);
    return record?.toEntity();
  }

  @override
  Future<Record> save(Record record) async {
    final id = _recordsBox.put(RecordModel.fromEntity(record));

    return record.copyWith(id: id);
  }

  @override
  Stream<List<Record>> getRecordsStream() {
    return _recordsBox
        .query()
        .order(RecordModel_.createdAt, flags: Order.descending)
        .watch(triggerImmediately: true)
        .map((query) {
          return query
              .find()
              .map((record) => record.toEntity())
              .toList(growable: false);
        });
  }
}
