import 'dart:async';
import 'package:flutter/cupertino.dart';

mixin DisposableWidget {
  final Set<StreamSubscription> _subscriptions = {};
  final Set<BuildContext> dialogContexts = {};

  void cancelSubscriptions() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  void addSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  void dismissDialogs() {
    for (var dialogContext in dialogContexts) {
      _dismissDialog(dialogContext);
    }
    dialogContexts.clear();
  }

  void addDialog(BuildContext context) {
    dialogContexts.add(context);
  }

  void _dismissDialog(BuildContext context) {
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
  }
}

extension DisposableStreamSubscriton on StreamSubscription {
  void canceledBy(DisposableWidget state) {
    state.addSubscription(this);
  }
}
