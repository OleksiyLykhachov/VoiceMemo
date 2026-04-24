import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'recording_exceptions.dart';

abstract interface class RecorderService {
  Future<void> dispose();
  Future<bool> hasPermission();
  Future<bool> requestPermission();

  Future<Stream<Uint8List>> start();
  Future<File> stop();
  Future<void> cancel();

  Future<void> pause();
  Future<void> resume();
}

@Injectable(as: RecorderService)
class RecordServiceImpl implements RecorderService {
  final AudioRecorder _recorder;

  File? _currentFile;
  IOSink? _output;
  Completer<void>? _recordingClosed;
  bool _isStarting;

  RecordServiceImpl({
    required AudioRecorder recorder,
  }) : _recorder = recorder,
       _currentFile = null,
       _isStarting = false;

  @override
  Future<void> dispose() async {
    try {
      await _recorder.stop();
    } catch (_) {}

    await _closeOutput();
    _clearSessionState();
    await _recorder.dispose();
  }

  @override
  Future<bool> hasPermission() {
    return _recorder.hasPermission(request: false);
  }

  @override
  Future<bool> requestPermission() {
    return _recorder.hasPermission();
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
  Future<Stream<Uint8List>> start() async {
    if (_isStarting || _currentFile != null) {
      throw RecordingException.alreadyInProgress();
    }

    if (!await requestPermission()) {
      throw RecordingException.permission();
    }

    _isStarting = true;
    final file = await _getFile();

    try {
      final sourceStream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
        ),
      );
      final stream = sourceStream.asBroadcastStream();

      final output = file.openWrite();
      final recordingClosed = Completer<void>();

      _currentFile = file;
      _output = output;
      _recordingClosed = recordingClosed;

      stream.listen(
        output.add,
        onError: (Object error, StackTrace stackTrace) {
          unawaited(_closeOutput());
        },
        onDone: () {
          unawaited(_closeOutput());
        },
        cancelOnError: true,
      );

      return stream;
    } catch (_) {
      await _discardFile(file);
      _clearSessionState();
      rethrow;
    } finally {
      _isStarting = false;
    }
  }

  Future<File> _getFile() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final recordsDirectory = Directory(
      path.join(documentsDirectory.path, 'records'),
    );

    if (!await recordsDirectory.exists()) {
      await recordsDirectory.create(recursive: true);
    }

    final fileName = 'record_${DateTime.now().microsecondsSinceEpoch}.pcm';
    final file = File(path.join(recordsDirectory.path, fileName));
    await file.create();

    return file;
  }

  @override
  Future<File> stop() async {
    final file = _currentFile;
    if (file == null) {
      throw RecordingException.notStarted();
    }

    final recordingClosed = _recordingClosed;

    try {
      await _recorder.stop();
      if (recordingClosed != null) {
        await recordingClosed.future;
      }
    } finally {
      _clearSessionState();
    }

    return file;
  }

  @override
  Future<void> cancel() async {
    final file = _currentFile;
    final recordingClosed = _recordingClosed;

    try {
      await _recorder.cancel();
      if (recordingClosed != null) {
        await recordingClosed.future;
      }
    } finally {
      _clearSessionState();
    }

    await _discardFile(file);
  }

  Future<void> _closeOutput() async {
    final output = _output;
    final recordingClosed = _recordingClosed;

    _output = null;
    _currentFile = null;

    if (output != null) {
      try {
        await output.flush();
      } finally {
        await output.close();
      }
    }

    if (recordingClosed != null && !recordingClosed.isCompleted) {
      recordingClosed.complete();
    }
  }

  void _clearSessionState() {
    _currentFile = null;
    _output = null;
    _recordingClosed = null;
  }

  Future<void> _discardFile(File? file) async {
    if (file == null || !await file.exists()) {
      return;
    }

    await file.delete();
  }
}
