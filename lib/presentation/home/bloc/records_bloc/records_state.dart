part of 'records_bloc.dart';

@freezed
abstract class RecordsState with _$RecordsState {
  const RecordsState._();
  const factory RecordsState({
    @Default([]) List<Record> records,
    @Default(false) bool loading,
  }) = _RecordsState;

  bool get showLoader {
    return records.isEmpty && loading;
  }
}
