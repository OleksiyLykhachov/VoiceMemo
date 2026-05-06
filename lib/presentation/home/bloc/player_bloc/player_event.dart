part of 'player_bloc.dart';

@freezed
class PlayerEvent with _$PlayerEvent {
  const factory PlayerEvent.setRecord(Record record) = _SetRecord;
  const factory PlayerEvent.reset() = _Reset;
  const factory PlayerEvent.togglePlay() = _TogglePlay;
  const factory PlayerEvent.seekForward(Duration duration) = _SeekForward;
  const factory PlayerEvent.seekBackward(Duration duration) = _SeekBackward;

  const factory PlayerEvent.setPlayerState(
    bool playing,
    Duration position,
  ) = _SetPlayerState;
}
