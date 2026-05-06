import 'dart:async';
import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'amplitude_data.dart';
import 'recording_exceptions.dart';

export 'amplitude_data.dart';
export 'recording_exceptions.dart';

abstract interface class RecorderService {
  Future<bool> get isHasPermission;
  Future<bool> requestPermission();
  Future<bool> resolvePermission();

  Future<void> dispose();

  Future<void> start();
  Future<File> stop();
  Future<void> cancel();

  Stream<AmplitudeData> getAmplitudeStream();

  Future<void> pause();
  Future<void> resume();
}

@Injectable(as: RecorderService)
class RecordServiceImpl implements RecorderService {
  final AudioRecorder _recorder;

  RecordServiceImpl({
    required AudioRecorder recorder,
  }) : _recorder = recorder;

  @override
  Future<void> dispose() async {
    await _recorder.dispose();
  }

  @override
  Future<bool> get isHasPermission {
    return _recorder.hasPermission(request: false);
  }

  @override
  Future<bool> requestPermission() {
    return _recorder.hasPermission();
  }

  @override
  Future<bool> resolvePermission() async {
    if (await isHasPermission) {
      return true;
    }

    return requestPermission();
  }

  @override
  Future<void> pause() {
    return _recorder.pause();
  }

  @override
  Future<void> resume() {
    return _recorder.resume();
  }

  @override
  Future<void> start() async {
    if (await _recorder.isRecording()) {
      throw RecordingException.alreadyInProgress();
    }

    if (!await resolvePermission()) {
      throw RecordingException.permission();
    }

    await _recorder.start(
      RecordConfig(encoder: AudioEncoder.flac),
      path: await _getPath(),
    );
  }

  Future<String> _getPath() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final recordsDirectory = Directory(
      path.join(documentsDirectory.path, 'records'),
    );

    if (!await recordsDirectory.exists()) {
      await recordsDirectory.create(recursive: true);
    }

    final fileName = 'record_${DateTime.now().microsecondsSinceEpoch}.flac';

    return path.join(recordsDirectory.path, fileName);
  }

  @override
  Future<File> stop() async {
    final isRecording = await _recorder.isRecording();

    if (!isRecording) {
      throw RecordingException.notStarted();
    }

    final path = await _recorder.stop();

    if (path == null) {
      throw RecordingException.recordingNotSaved();
    }

    return File(path);
  }

  @override
  Future<void> cancel() async {
    return _recorder.cancel();
  }

  @override
  Stream<AmplitudeData> getAmplitudeStream() {
    return _recorder.onAmplitudeChanged(const Duration(milliseconds: 50)).map(
      (amplitude) {
        return AmplitudeData(
          current: amplitude.current,
          max: amplitude.max,
        );
      },
    );
  }
}
