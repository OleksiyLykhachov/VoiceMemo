import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:voice_memos/presentation/presentation.dart';

class NotificationToast extends StatelessWidget {
  final Widget icon;
  final Widget title;

  const NotificationToast({
    required this.icon,
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 16,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: VoiceMemosColors.black,
        borderRadius: const BorderRadius.all(Radius.circular(18)),
      ),

      child: Row(
        children: [
          icon,
          const Gap(8),
          Expanded(
            child: DefaultTextStyle(
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: VoiceMemosColors.white,
              ),
              child: title,
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;

  const NotificationIcon({
    required this.icon,
    required this.color,
    required this.background,
    super.key,
  });

  const NotificationIcon.failure(this.icon, {super.key})
    : color = VoiceMemosColors.white,
      background = VoiceMemosColors.red;

  const NotificationIcon.success(this.icon, {super.key})
    : color = VoiceMemosColors.black,
      background = VoiceMemosColors.white;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 18,
      ),
    );
  }
}
