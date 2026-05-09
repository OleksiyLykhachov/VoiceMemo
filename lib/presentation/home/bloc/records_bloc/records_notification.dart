part of 'records_bloc.dart';

@freezed
sealed class RecordsNotification with _$RecordsNotification {
  const factory RecordsNotification.failure(String message) = _Failure;
  const factory RecordsNotification.renamed(Record record) = _Renamed;
  const factory RecordsNotification.deleted(Record record) = _Deleted;
}
