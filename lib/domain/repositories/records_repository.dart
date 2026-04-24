import '../entities/record.dart';

abstract interface class RecordsRepository {
  Future<List<Record>> getRecords();
  Future<Record?> getRecordById(int id);
  Stream<List<Record>> getRecordsStream();
  Future<void> delete(int id);
  Future<Record> save(Record record);
}
