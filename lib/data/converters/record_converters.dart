import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:voice_memos/domain/domain.dart';
import 'package:voice_memos/utils/utils.dart';

import '../models/record_model.dart';

@Injectable(as: Converter<Record, RecordModel>)
class RecordConverter extends Converter<Record, RecordModel> {
  final RecordsPathUtil _pathUtil;

  RecordConverter({required RecordsPathUtil pathUtil}) : _pathUtil = pathUtil;

  @override
  RecordModel convert(Record input) {
    return RecordModel(
      objectBoxId: input.id,
      name: input.name,
      createdAt: input.createdAt,
      filePath: _pathUtil.toStoredPath(input.filePath),
      duration: input.duration,
    );
  }
}

@Injectable(as: Converter<RecordModel, Record>)
class RecordModelConverter extends Converter<RecordModel, Record> {
  final RecordsPathUtil _pathUtil;

  RecordModelConverter({required RecordsPathUtil pathUtil})
    : _pathUtil = pathUtil;

  @override
  Record convert(RecordModel input) {
    return Record(
      id: input.objectBoxId,
      name: input.name,
      createdAt: input.createdAt,
      filePath: _pathUtil.resolveStoredPath(input.filePath),
      duration: input.duration,
    );
  }
}
