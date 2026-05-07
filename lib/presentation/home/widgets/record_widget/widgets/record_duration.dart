import 'package:flutter/widgets.dart';
import 'package:voice_memos/presentation/presentation.dart';
import 'package:voice_memos/utils/utils.dart';

class RecordDuration extends StatelessWidget {
  final int ms;

  const RecordDuration({
    required this.ms,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final duration = Duration(milliseconds: ms);

    return Text(
      duration.getFormattedString(),
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: VoiceMemosColors.textSecondary,
      ),
    );
  }
}
