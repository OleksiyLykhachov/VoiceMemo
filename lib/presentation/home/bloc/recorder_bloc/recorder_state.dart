part of 'recorder_bloc.dart';

@freezed
abstract class RecorderState with _$RecorderState {
  const factory RecorderState({
    Stream<Uint8List>? recordingStream,
    @Default(false) bool recording,
    @Default(false) bool show,
    DateTime? startedAt,
  }) = _RecorderState;
}
