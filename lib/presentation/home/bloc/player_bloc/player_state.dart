part of 'player_bloc.dart';

@freezed
abstract class PlayerState with _$PlayerState {
  const PlayerState._();
  const factory PlayerState({
    Record? record,
    @Default(false) bool playing,
    Duration? position,
  }) = _PlayerState;

  double get progress {
    if (record == null) {
      return 0;
    }

    final duration = record!.duration;
    if (duration <= 0) {
      return 0;
    }

    final progress = (position?.inMilliseconds ?? 0) / duration;
    if (progress <= 0) {
      return 0;
    }
    if (progress >= 1) {
      return 1;
    }
    return progress;
  }
}
