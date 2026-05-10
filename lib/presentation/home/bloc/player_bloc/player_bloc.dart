import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import 'package:voice_memos/domain/domain.dart';
import 'package:voice_memos/utils/utils.dart';

part 'player_event.dart';
part 'player_state.dart';
part 'player_notification.dart';
part 'player_bloc.freezed.dart';

@injectable
class PlayerBloc extends Bloc<PlayerEvent, PlayerState>
    with
        BlocNotificationMixin<PlayerNotification, PlayerState>,
        ErrorNotificationMixin {
  final PlayerService _playerService;
  late final StreamSubscription? _sub;

  PlayerBloc({required PlayerService playerService})
    : _playerService = playerService,
      super(const PlayerState()) {
    on<_SetRecord>(
      _onSetRecord,
      transformer: debounceRestartable(const Duration(milliseconds: 250)),
    );
    on<_Pause>(_onPause);
    on<_TogglePlay>(_onTogglePlay);
    on<_SeekForward>(_onSeekForward);
    on<_SeekBackward>(_onSeekBackward);

    on<_SetPlayerState>(_onSetPlayerState);

    _sub = _playerService.stateStream.listen((state) {
      add(_SetPlayerState(state.playing, state.position));
    });
  }

  FutureOr<void> _onSetRecord(
    _SetRecord event,
    Emitter<PlayerState> emit,
  ) async {
    final record = event.record;

    if (record == state.record) {
      return;
    }

    return handle(() async {
      await _playerService.pause();
      await _playerService.init(File(record.filePath));

      emit(PlayerState(record: record));
    }, errorMessage: 'Could not open the recording. Please try again.');
  }

  FutureOr<void> _onPause(_Pause event, Emitter<PlayerState> emit) async {
    if (!state.playing) {
      return;
    }

    return handle(() async {
      await _playerService.pause();
    }, errorMessage: 'Could not pause the recording. Please try again.');
  }

  FutureOr<void> _onTogglePlay(
    _TogglePlay event,
    Emitter<PlayerState> emit,
  ) async {
    if (state.record == null) {
      return;
    }

    return handle(
      () async {
        if (state.playing) {
          await _playerService.pause();
        } else {
          await _playerService.play();
        }
      },
      buildMessage: (_) {
        return state.playing
            ? 'Could not pause the recording. Please try again.'
            : 'Could not play the recording. Please try again.';
      },
    );
  }

  FutureOr<void> _onSeekForward(
    _SeekForward event,
    Emitter<PlayerState> emit,
  ) async {
    final record = state.record;

    if (record == null) {
      return;
    }

    final maxPosition = record.duration;
    final nextPosition = _playerService.position + event.duration;

    return handle(() async {
      await _playerService.seek(
        nextPosition > maxPosition ? maxPosition : nextPosition,
      );
    }, errorMessage: 'Could not skip forward. Please try again.');
  }

  FutureOr<void> _onSeekBackward(
    _SeekBackward event,
    Emitter<PlayerState> emit,
  ) async {
    if (state.record == null) {
      return;
    }

    final nextPosition = _playerService.position - event.duration;

    return handle(() async {
      await _playerService.seek(
        nextPosition.isNegative ? Duration.zero : nextPosition,
      );
    }, errorMessage: 'Could not skip backward. Please try again.');
  }

  @override
  Future<void> close() async {
    await Future.wait([
      if (_sub != null) _sub.cancel(),
      _playerService.dispose(),
    ]);
    return super.close();
  }

  FutureOr<void> _onSetPlayerState(
    _SetPlayerState event,
    Emitter<PlayerState> emit,
  ) {
    emit(state.copyWith(position: event.position, playing: event.playing));
  }

  @override
  void showError(String error) {
    emitNotification(PlayerNotification.failure(error));
  }
}
