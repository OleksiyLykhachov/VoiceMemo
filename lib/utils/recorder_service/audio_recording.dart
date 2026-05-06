import 'dart:io';

class AudioRecording {
  final File file;
  final Duration? duration;

  const AudioRecording({
    required this.file,
    required this.duration,
  });
}
