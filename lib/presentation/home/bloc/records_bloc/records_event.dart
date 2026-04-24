part of 'records_bloc.dart';

@freezed
sealed class RecordsEvent with _$RecordsEvent {
  const factory RecordsEvent.load() = _Load;
  const factory RecordsEvent.save({
    required File file,
    required String name,
    required Duration duration,
  }) = _Save;

  const factory RecordsEvent.rename({
    required int id,
    required String name,
    
  }) = _Rename;

  const factory RecordsEvent.delete(int id) = _Delete;
}
