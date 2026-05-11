import 'package:flutter/material.dart';

import 'layout_constants.dart';
import 'platform_detector.dart';

/// Global key for the root ScaffoldMessenger, allowing snackbars to survive navigation.
final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Nested messenger inside MainScreen — its Scaffold owns the bottom NavigationBar
/// so floating snackbars auto-offset above the navbar.
final mainScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Types of snackbars available in the app
enum SnackBarType { info, success, error }

const double _kDesktopSnackBarWidth = 480.0;

/// Builds a [SnackBar] with desktop-aware width and optional dismiss button.
///
/// [dismissible] : null = auto (shows X on desktop), true/false to override.
SnackBar _buildSnackBar(
  ScaffoldMessengerState messenger, {
  required Widget content,
  required Color? backgroundColor,
  required Duration duration,
  bool? dismissible,
}) {
  final isDesktop = PlatformDetector.isDesktopOS();
  final showX = dismissible ?? isDesktop;

  final body = showX
      ? Row(
          children: [
            Expanded(child: content),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: messenger.hideCurrentSnackBar,
                  borderRadius: BorderRadius.circular(16),
                  splashColor: Colors.white30,
                  hoverColor: Colors.white24,
                  highlightColor: Colors.white38,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close, size: 18, color: Colors.white70),
                  ),
                ),
              ),
            ),
          ],
        )
      : content;

  return SnackBar(
    content: body,
    backgroundColor: backgroundColor,
    duration: duration,
    behavior: isDesktop ? SnackBarBehavior.floating : null,
    width: isDesktop ? _kDesktopSnackBarWidth : null,
  );
}

(Color?, Duration) _snackBarStyle(SnackBarType type) => switch (type) {
      SnackBarType.info => (null, AppDurations.snackBarDefault),
      SnackBarType.success => (Colors.green, AppDurations.snackBarDefault),
      SnackBarType.error => (Colors.red, AppDurations.snackBarLong),
    };

/// Utility functions for showing snackbars throughout the application

void showSnackBar(
  BuildContext context,
  String message, {
  SnackBarType type = SnackBarType.info,
  Duration? duration,
  bool? dismissible,
}) {
  if (!context.mounted) return;
  final (backgroundColor, defaultDuration) = _snackBarStyle(type);
  final messenger = ScaffoldMessenger.of(context);
  messenger.showSnackBar(_buildSnackBar(
    messenger,
    content: Text(message),
    backgroundColor: backgroundColor,
    duration: duration ?? defaultDuration,
    dismissible: dismissible,
  ));
}

/// Shows a snackbar with a custom widget as content.
void showWidgetSnackBar(
  BuildContext context,
  Widget content, {
  SnackBarType type = SnackBarType.info,
  Duration? duration,
  bool? dismissible,
}) {
  if (!context.mounted) return;
  final (backgroundColor, defaultDuration) = _snackBarStyle(type);
  final messenger = ScaffoldMessenger.of(context);
  messenger.showSnackBar(_buildSnackBar(
    messenger,
    content: content,
    backgroundColor: backgroundColor,
    duration: duration ?? defaultDuration,
    dismissible: dismissible,
  ));
}

void showAppSnackBar(BuildContext context, String message, {Duration? duration}) {
  showSnackBar(context, message, type: SnackBarType.info, duration: duration);
}

void showErrorSnackBar(BuildContext context, String message) {
  showSnackBar(context, message, type: SnackBarType.error);
}

/// Shows an error snackbar using the root ScaffoldMessenger (survives navigation).
void showGlobalErrorSnackBar(String message) {
  final messenger = rootScaffoldMessengerKey.currentState;
  if (messenger == null) return;
  messenger.showSnackBar(_buildSnackBar(
    messenger,
    content: Text(message),
    backgroundColor: Colors.red,
    duration: AppDurations.snackBarLong,
  ));
}

/// Shows an info snackbar through the main-screen messenger when available
/// (so it floats above the mobile NavigationBar), falling back to the root
/// messenger when the main screen is not mounted.
void showMainSnackBar(String message, {Duration duration = AppDurations.snackBarDefault}) {
  final messenger = mainScaffoldMessengerKey.currentState ?? rootScaffoldMessengerKey.currentState;
  if (messenger == null) return;
  messenger
    ..removeCurrentSnackBar()
    ..showSnackBar(_buildSnackBar(
      messenger,
      content: Text(message),
      backgroundColor: null,
      duration: duration,
    ));
}

void showSuccessSnackBar(BuildContext context, String message) {
  showSnackBar(context, message, type: SnackBarType.success);
}
