import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:voice_memos/presentation/presentation.dart';

class BaseBottomSheet extends StatelessWidget {
  final Widget child;

  const BaseBottomSheet({
    required this.child,
    super.key,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      builder: builder,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: VoiceMemosColors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(child: _Grabber()),
          const Gap(14),
          SafeArea(child: child),
        ],
      ),
    );
  }
}

class _Grabber extends StatelessWidget {
  const _Grabber();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      width: 38,
      decoration: BoxDecoration(
        color: VoiceMemosColors.textTertiary,
        borderRadius: const BorderRadius.all(Radius.circular(2)),
      ),
    );
  }
}
