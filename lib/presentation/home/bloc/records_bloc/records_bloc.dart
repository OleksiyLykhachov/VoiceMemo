import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
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
    on<_Rename>(_onRename, transformer: sequential());
    on<_Delete>(_onDelete, transformer: sequential());
    on<_Load>(_onLoad, transformer: droppable());
  }

  FutureOr<void> _onSave(_Save event, Emitter<RecordsState> emit) {
    return handle(() async {
      final record = await _repository.save(
        Record(
          id: 0,
          name: event.name,
          filePath: event.file.path,
          createdAt: DateTime.now(),
          durationMs: event.duration.inMilliseconds,
        ),
      );

      emit(state.copyWith(records: [record, ...state.records]));
      emitNotification(RecordsNotification.saved(record));
    }, errorMessage: 'Could not save your recording. Please try again.');
  }

  FutureOr<void> _onRename(_Rename event, Emitter<RecordsState> emit) {
    final oldRecords = state.records;

    return handle(
      () async {
        final updatedRecords =
            state.records
                .map(
                  (record) =>
                      record.id == event.id
                          ? record.copyWith(name: event.name)
                          : record,
                )
                .toList();

        emit(state.copyWith(records: updatedRecords));

        final record = updatedRecords.firstWhere(
          (record) => record.id == event.id,
        );
        await _repository.save(record);

        emitNotification(RecordsNotification.renamed(record));
      },
      onFailure: (_) {
        emit(state.copyWith(records: oldRecords));
      },
      errorMessage: 'Could not rename the recording. Please try again.',
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
      errorMessage: 'Could not load your recordings. Please try again.',
    );
  }

  FutureOr<void> _onDelete(_Delete event, Emitter<RecordsState> emit) {
    final oldRecords = state.records;

    return handle(
      () async {
        final updatedRecords = [...state.records];

        final record = updatedRecords.removeWhereAndReturn((item) {
          return item.id == event.id;
        });

        emit(state.copyWith(records: updatedRecords));

        await _repository.delete(event.id);

        emitNotification(RecordsNotification.deleted(record));
      },
      onFailure: (error) {
        emit(state.copyWith(records: oldRecords));
      },
      errorMessage: 'Could not delete the recording. Please try again.',
    );
  }

  @override
  void showError(String error) {
    emitNotification(RecordsNotification.failure(error));
  }
}
