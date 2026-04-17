import 'package:freezed_annotation/freezed_annotation.dart';

part 'record.freezed.dart';

@freezed
abstract class Record with _$Record {
  const factory Record({
    required int id,
    required String name,
    required DateTime createdAt,
    required String filePath,
    required int duration,
  }) = _Record;
}
