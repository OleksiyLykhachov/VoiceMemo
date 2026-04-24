part of 'recorder_bloc.dart';

@freezed
class RecorderEvent with _$RecorderEvent {
  const factory RecorderEvent.start() = _Start;
  const factory RecorderEvent.stop() = _Stop;
}
