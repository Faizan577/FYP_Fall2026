import 'package:flutter/material.dart';

import '../providers/auth_scope.dart';

abstract final class ProtectedFeatureNavigation {
  static void open(
    BuildContext context, {
    required WidgetBuilder destination,
    required Widget Function(WidgetBuilder destination) loginScreenBuilder,
  }) {
    final auth = AuthScope.of(context);
    final route = MaterialPageRoute<void>(
      builder: auth.isAuthenticated && !auth.isGuest
          ? destination
          : (_) => loginScreenBuilder(destination),
    );
    Navigator.of(context).push(route);
  }

  static void completeAuthentication(
    BuildContext context, {
    required WidgetBuilder? destination,
    required WidgetBuilder fallbackDestination,
  }) {
    final navigator = Navigator.of(context);
    if (destination != null) {
      navigator.pushReplacement(
        MaterialPageRoute<void>(builder: destination),
      );
      return;
    }
    navigator.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: fallbackDestination),
      (_) => false,
    );
  }
}
