import 'dart:async';

import 'package:bloc/bloc.dart';

mixin BlocNotificationMixin<Notification, State> on BlocBase<State> {
  final StreamController<Notification> _notificationController =
      StreamController.broadcast();

  void emitNotification(Notification notification) {
    _notificationController.add(notification);
  }

  Stream<Notification> get notificationStream => _notificationController.stream;

  @override
  Future<void> close() async {
    await _notificationController.close();
    return super.close();
  }
}
