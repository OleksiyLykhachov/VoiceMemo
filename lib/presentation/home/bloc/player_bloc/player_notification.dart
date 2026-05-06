part of 'player_bloc.dart';

@freezed
sealed class PlayerNotification with _$PlayerNotification {
  const factory PlayerNotification.failure(String message) = _Failure;
}
