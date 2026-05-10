import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';

import 'package:voice_memos/presentation/presentation.dart';

class RecordOptionItem extends StatelessWidget {
  final Widget title;
  final Widget subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  final RecordOptionColors colors;

  const RecordOptionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.colors = const RecordOptionColors.standard(),
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            CircleIcon(
              background: colors.iconBackground,
              foreground: colors.iconForeground,
              icon: icon,
              size: 20,
            ),
            const Gap(8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle(
                    style: VoiceMemosTextStyles.bodyLarge.copyWith(
                      color: colors.title,
                      fontWeight: FontWeight.w600,
                    ),
                    child: title,
                  ),
                  DefaultTextStyle(
                    style: VoiceMemosTextStyles.labelMedium.copyWith(
                      color: colors.subtitle,
                      fontWeight: FontWeight.w600,
                    ),
                    child: subtitle,
                  ),
                ],
              ),
            ),
            Icon(CupertinoIcons.forward, size: 23, color: colors.arrow),
          ],
        ),
      ),
    );
  }
}

class RecordOptionColors {
  final Color iconBackground;
  final Color iconForeground;
  final Color border;
  final Color background;
  final Color title;
  final Color subtitle;
  final Color arrow;

  const RecordOptionColors.standard({
    this.iconBackground = VoiceMemosColors.faint,
    this.iconForeground = VoiceMemosColors.black,
    this.border = VoiceMemosColors.border,
    this.background = VoiceMemosColors.white,
    this.title = VoiceMemosColors.black,
    this.subtitle = VoiceMemosColors.textSecondary,
    this.arrow = VoiceMemosColors.textSecondary,
  });

  RecordOptionColors.destructive({
    this.iconBackground = VoiceMemosColors.red,
    this.iconForeground = VoiceMemosColors.white,
    this.border = VoiceMemosColors.red,
    this.background = VoiceMemosColors.white,
    this.title = VoiceMemosColors.red,
    this.subtitle = VoiceMemosColors.textSecondary,
    this.arrow = VoiceMemosColors.red,
  });
}
