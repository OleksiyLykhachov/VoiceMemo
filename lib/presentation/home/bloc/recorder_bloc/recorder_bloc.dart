import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:voice_memos/utils/utils.dart';

part 'recorder_event.dart';
part 'recorder_state.dart';
part 'recorder_notification.dart';
part 'recorder_bloc.freezed.dart';

@injectable
class RecorderBloc extends Bloc<RecorderEvent, RecorderState>
    with
        BlocNotificationMixin<RecorderNotification, RecorderState>,
        ErrorNotificationMixin {
  final RecorderService _recorderService;

  RecorderBloc({required RecorderService recorderService})
    : _recorderService = recorderService,
      super(const RecorderState()) {
    on<_Start>(_onStart, transformer: droppable());
    on<_Stop>(_onStop, transformer: droppable());
  }

  FutureOr<void> _onStart(_Start event, Emitter<RecorderState> emit) {
    return handle(() async {
      if (state.recording) {
        return;
      }

      final hasPermission = await _recorderService.resolvePermission();

      if (!hasPermission) {
        await _recorderService.requestPermission();
      }

      emit(state.copyWith(show: true));

      await _recorderService.start();
      final stream = _recorderService.getAmplitudeStream();

      emit(
        state.copyWith(
          amplitudeStream: stream,
          recording: true,
          startedAt: DateTime.now(),
        ),
      );
    });
  }

  FutureOr<void> _onStop(_Stop event, Emitter<RecorderState> emit) {
    return handle(() async {
      final stopDate = DateTime.now();
      final recording = await _recorderService.stop();

      emitNotification(
        RecorderNotification.recorded(
          recording.file,
          recording.duration ?? stopDate.difference(state.startedAt!),
        ),
      );

      emit(
        state.copyWith(
          show: false,
          recording: false,
          amplitudeStream: null,
          startedAt: null,
        ),
      );
    });
  }

  @override
  void showError(String error) {
    emitNotification(RecorderNotification.failure(error));
  }

  @override
  Future<void> close() async {
    await _recorderService.dispose();
    return super.close();
  }
}
