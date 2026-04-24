class RecordingException implements Exception {
  final String message;
  final RecordingExceptionType type;

  const RecordingException({
    required this.message,
    required this.type,
  });

  const RecordingException.permission()
    : type = RecordingExceptionType.permissionNotGranted,
      message = 'Microphone permission not granted';

  const RecordingException.alreadyInProgress()
    : type = RecordingExceptionType.recordingAlreadyInProgress,
      message = 'Recording is already in progress';

  const RecordingException.notStarted()
    : type = RecordingExceptionType.recordingNotStarted,
      message = 'Recording has not been started';
}

enum RecordingExceptionType {
  permissionNotGranted,
  recordingAlreadyInProgress,
  recordingNotStarted,
}
