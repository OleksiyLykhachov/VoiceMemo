import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'package:voice_memos/presentation/presentation.dart';

class RecordingDuration extends StatefulWidget {
  static const _refreshInterval = Duration(milliseconds: 5);

  final DateTime startDateTime;

  const RecordingDuration(
    this.startDateTime, {
    super.key,
  });

  @override
  State<RecordingDuration> createState() => _RecordingDurationState();
}

class _RecordingDurationState extends State<RecordingDuration> {
  static final NumberFormat _twoDigitsFormat = NumberFormat('00');

  late Timer _timer;
  late Duration _elapsed;

  @override
  void initState() {
    super.initState();
    _elapsed = _currentElapsed;
    _timer = Timer.periodic(RecordingDuration._refreshInterval, (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _elapsed = _currentElapsed;
      });
    });
  }

  @override
  void didUpdateWidget(covariant RecordingDuration oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.startDateTime == widget.startDateTime) {
      return;
    }

    _elapsed = _currentElapsed;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Duration get _currentElapsed {
    return DateTime.now().difference(widget.startDateTime);
  }

  String get _formattedElapsed {
    final hours = _elapsed.inHours;
    final minutes = _elapsed.inMinutes.remainder(60);
    final seconds = _elapsed.inSeconds.remainder(60);
    final centiseconds = (_elapsed.inMilliseconds ~/ 10).remainder(100);

    final hoursPrefix = hours == 0
        ? ''
        : '${_twoDigitsFormat.format(hours)}:';

    return '$hoursPrefix${_twoDigitsFormat.format(minutes)}:'
        '${_twoDigitsFormat.format(seconds)},'
        '${_twoDigitsFormat.format(centiseconds)}';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formattedElapsed,
      style: const TextStyle(
        color: VoiceMemosColors.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
    );
  }
}
