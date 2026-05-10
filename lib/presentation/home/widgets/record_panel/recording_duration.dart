import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'package:voice_memos/presentation/presentation.dart';
import 'package:voice_memos/utils/utils.dart';

class RecordingDuration extends StatefulWidget {
  final DateTime startDateTime;

  const RecordingDuration(this.startDateTime, {super.key});

  @override
  State<RecordingDuration> createState() => _RecordingDurationState();
}

class _RecordingDurationState extends State<RecordingDuration>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late String _formattedElapsed;

  @override
  void initState() {
    super.initState();
    _formattedElapsed = _currentElapsed.getFormattedString(true);
    _ticker = createTicker((_) {
      final formattedElapsed = _currentElapsed.getFormattedString(true);
      if (formattedElapsed == _formattedElapsed || !mounted) {
        return;
      }

      setState(() {
        _formattedElapsed = formattedElapsed;
      });
    })..start();
  }

  @override
  void didUpdateWidget(covariant RecordingDuration oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.startDateTime == widget.startDateTime) {
      return;
    }

    _formattedElapsed = _currentElapsed.getFormattedString(true);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  Duration get _currentElapsed {
    return DateTime.now().difference(widget.startDateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formattedElapsed,
      style: VoiceMemosTextStyles.labelLarge.copyWith(
        color: VoiceMemosColors.textSecondary,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
