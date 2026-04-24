import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:voice_memos/domain/domain.dart';
import 'package:voice_memos/utils/utils.dart';

part 'records_event.dart';
part 'records_state.dart';
part 'records_notification.dart';
part 'records_bloc.freezed.dart';

@injectable
class RecordsBloc extends Bloc<RecordsEvent, RecordsState>
    with
        BlocNotificationMixin<RecordsNotification, RecordsState>,
        ErrorNotificationMixin {
  final RecordsRepository _repository;

  RecordsBloc({required RecordsRepository repository})
    : _repository = repository,
      super(const RecordsState()) {
    on<_Save>(_onSave);
    on<_Rename>(_onRename);
    on<_Delete>(_onDelete);
    on<_Load>(_onLoad);
  }

  FutureOr<void> _onSave(_Save event, Emitter<RecordsState> emit) {
    return handle(
      () async {
        final record = await _repository.save(
          Record(
            id: 0,
            name: event.name,
            filePath: event.file.path,
            createdAt: DateTime.now(),
            duration: event.duration.inMilliseconds,
          ),
        );

        emit(state.copyWith(records: [record, ...state.records]));
      },
    );
  }

  FutureOr<void> _onRename(_Rename event, Emitter<RecordsState> emit) {
    final oldRecords = state.records;

    return handle(
      () async {
        final updatedRecords = state.records
            .map(
              (record) => record.id == event.id
                  ? record.copyWith(name: event.name)
                  : record,
            )
            .toList();

        emit(state.copyWith(records: updatedRecords));

        final record = updatedRecords.firstWhere(
          (record) => record.id == event.id,
        );
        await _repository.save(record);
      },
      onFailure: (_) {
        emit(state.copyWith(records: oldRecords));
      },
    );
  }

  FutureOr<void> _onLoad(_Load event, Emitter<RecordsState> emit) {
    return handle(
      () async {
        emit(state.copyWith(loading: true));

        final records = await _repository.getRecords();

        emit(state.copyWith(records: records));
      },
      onFinally: () {
        emit(state.copyWith(loading: false));
      },
    );
  }

  FutureOr<void> _onDelete(_Delete event, Emitter<RecordsState> emit) {
    final oldRecords = state.records;

    return handle(
      () async {
        final updatedRecords = state.records
            .where((record) => record.id != event.id)
            .toList();

        emit(state.copyWith(records: updatedRecords));

        await _repository.delete(event.id);
      },
      onFailure: (_) {
        emit(state.copyWith(records: oldRecords));
      },
    );
  }

  @override
  void showError(String error) {
    emitNotification(RecordsNotification.failure(error));
  }
}
