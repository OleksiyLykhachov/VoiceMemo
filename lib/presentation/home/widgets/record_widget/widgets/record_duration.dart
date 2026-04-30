import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:voice_memos/presentation/presentation.dart';

class RecordDuration extends StatelessWidget {
  final int ms;
  const RecordDuration({
    required this.ms,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('00');
    final duration = Duration(milliseconds: ms);

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    final formatted =
        '${hours != 0 ? hours : ''}'
        '${formatter.format(minutes)}:'
        '${formatter.format(seconds)}';

    return Text(
      formatted,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: VoiceMemosColors.textSecondary,
      ),
    );
  }
}
