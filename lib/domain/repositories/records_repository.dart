import '../entities/record.dart';

abstract interface class RecordsRepository {
  Future<List<Record>> getRecords();
  Stream<List<Record>> getRecordsStream();
  Future<void> delete(int id);
  Future<void> save(Record record);
}
