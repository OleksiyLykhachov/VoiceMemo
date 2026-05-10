import 'package:flutter/material.dart';

import 'package:voice_memos/presentation/presentation.dart';

class BaseDialog extends StatelessWidget {
  final Widget child;

  const BaseDialog({required this.child, super.key});

  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) {
        return Center(child: builder(context));
      },
      useSafeArea: true,
      barrierDismissible: isDismissible,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: VoiceMemosColors.white,
      insetPadding: const EdgeInsets.all(24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
      child: Padding(padding: const EdgeInsets.all(24), child: child),
    );
  }
}
