import 'package:freezed_annotation/freezed_annotation.dart';

part 'record.freezed.dart';

@freezed
abstract class Record with _$Record {
  const Record._();

  const factory Record({
    required int id,
    required String name,
    required DateTime createdAt,
    required String filePath,
    required int durationMs,
  }) = _Record;

  Duration get duration {
    return Duration(milliseconds: durationMs);
  }
}
