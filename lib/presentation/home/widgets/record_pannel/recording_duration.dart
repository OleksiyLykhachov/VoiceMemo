import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:voice_memos/presentation/presentation.dart';
import 'package:voice_memos/utils/utils.dart';

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

  @override
  Widget build(BuildContext context) {
    return Text(
      _elapsed.getFormattedString(true),
      style: const TextStyle(
        color: VoiceMemosColors.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
    );
  }
}
