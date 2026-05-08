part of 'player_bloc.dart';

@freezed
abstract class PlayerState with _$PlayerState {
  const factory PlayerState({
    Record? record,
    @Default(false) bool playing,
    Duration? position,
  }) = _PlayerState;
}
