import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';

import 'package:voice_memos/presentation/presentation.dart';

class DialogContent extends StatelessWidget {
  final Widget icon;
  final Widget title;
  final Widget child;

  const DialogContent({
    required this.icon,
    required this.title,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const Gap(24),
        DefaultTextStyle(
          style: VoiceMemosTextStyles.headlineLarge.copyWith(
            color: VoiceMemosColors.black,
          ),
          child: title,
        ),
        const Gap(8),
        DefaultTextStyle(
          style: VoiceMemosTextStyles.bodyMedium.copyWith(
            color: VoiceMemosColors.textSecondary,
          ),
          child: child,
        ),
      ],
    );
  }
}
