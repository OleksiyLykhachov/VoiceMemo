part of 'recorder_bloc.dart';

@freezed
class RecorderNotification with _$RecorderNotification {
  const factory RecorderNotification.recorded(File file, Duration duration) =
      _Recorded;
  const factory RecorderNotification.failure(String message) =
      _FailureNotification;
}
