import 'package:flutter/material.dart';

import 'package:toastification/toastification.dart';
import 'package:voice_memos/utils/toast_notification/notification_toast.dart';

extension ToastNotificationExtension on BuildContext {
  void _showToast(Widget toast) {
    toastification.showCustom(
      context: this,
      autoCloseDuration: const Duration(seconds: 5),
      alignment: Alignment.topCenter,
      builder: (context, item) {
        return toast;
      },
    );
  }

  void showFailureToast(String title) {
    _showToast(
      NotificationToast(
        icon: NotificationIcon.failure(Icons.priority_high_rounded),
        title: Text(title),
      ),
    );
  }

  void showSuccessToast(String title) {
    _showToast(
      NotificationToast(
        icon: NotificationIcon.success(Icons.check),
        title: Text(title),
      ),
    );
  }
}
