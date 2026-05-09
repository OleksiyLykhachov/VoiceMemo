import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nested/nested.dart';

import 'bloc_notification_mixin.dart';

typedef NotificationHandler<N> =
    void Function(BuildContext context, N notification);

class BlocNotificationListener<N, B extends BlocNotificationMixin<N, Object?>>
    extends SingleChildStatefulWidget {
  const BlocNotificationListener({
    super.key,
    this.child,
    required this.listen,
  });

  final Widget? child;
  final NotificationHandler<N> listen;

  @override
  SingleChildState<BlocNotificationListener<N, B>> createState() =>
      _BlocNotificationListenerState<N, B>();
}

class _BlocNotificationListenerState<
  N,
  B extends BlocNotificationMixin<N, Object?>
>
    extends SingleChildState<BlocNotificationListener<N, B>> {
  late final StreamSubscription<N> _subscription;

  @override
  void initState() {
    super.initState();

    final bloc = context.read<B>();
    _subscription = bloc.notificationStream.listen(_onNotification);
  }

  void _onNotification(N event) {
    widget.listen(context, event);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? const SizedBox.shrink();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return child ?? const SizedBox.shrink();
  }
}
