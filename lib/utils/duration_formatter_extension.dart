import 'package:intl/intl.dart';

extension DurationFormatterX on Duration {
  String getFormattedString([bool includeMs = false]) {
    final numberFormat = NumberFormat('00');

    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);

    final hoursPrefix = hours == 0 ? '' : '$hours:';

    final formatted =
        '$hoursPrefix${numberFormat.format(minutes)}:'
        '${numberFormat.format(seconds)}';

    if (!includeMs) {
      return formatted;
    }

    final centiseconds = (inMilliseconds ~/ 10).remainder(100);
    
    return '$formatted,${numberFormat.format(centiseconds)}';
  }
}
