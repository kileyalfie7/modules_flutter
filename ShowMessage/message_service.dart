// notification_service.dart
import 'package:flutter/material.dart';

class NotificationService {
  static void showSuccess(
    BuildContext context, {
    required String title,
    String? message,
    Duration? duration,
    VoidCallback? onTap,
  }) {
    NotificationOverlay.show(
      context,
      NotificationConfig(
        title: title,
        message: message,
        type: NotificationType.success,
        duration: duration ?? const Duration(seconds: 3),
        onTap: onTap,
        showProgressBar: true,
      ),
    );
  }

  static void showError(
    BuildContext context, {
    required String title,
    String? message,
    Duration? duration,
    VoidCallback? onTap,
  }) {
    NotificationOverlay.show(
      context,
      NotificationConfig(
        title: title,
        message: message,
        type: NotificationType.error,
        duration: duration ?? const Duration(seconds: 4),
        onTap: onTap,
        showProgressBar: true,
      ),
    );
  }

  static void showWarning(
    BuildContext context, {
    required String title,
    String? message,
    Duration? duration,
    VoidCallback? onTap,
  }) {
    NotificationOverlay.show(
      context,
      NotificationConfig(
        title: title,
        message: message,
        type: NotificationType.warning,
        duration: duration ?? const Duration(seconds: 3),
        onTap: onTap,
        showProgressBar: true,
      ),
    );
  }

  static void showInfo(
    BuildContext context, {
    required String title,
    String? message,
    Duration? duration,
    VoidCallback? onTap,
  }) {
    NotificationOverlay.show(
      context,
      NotificationConfig(
        title: title,
        message: message,
        type: NotificationType.info,
        duration: duration ?? const Duration(seconds: 3),
        onTap: onTap,
        showProgressBar: true,
      ),
    );
  }

  static void showCustom(
    BuildContext context, {
    required String title,
    String? message,
    Color? backgroundColor,
    Color? textColor,
    Widget? customIcon,
    Duration? duration,
    NotificationPosition? position,
    VoidCallback? onTap,
    bool showProgressBar = false,
  }) {
    NotificationOverlay.show(
      context,
      NotificationConfig(
        title: title,
        message: message,
        type: NotificationType.custom,
        backgroundColor: backgroundColor,
        textColor: textColor,
        customIcon: customIcon,
        duration: duration ?? const Duration(seconds: 3),
        position: position ?? NotificationPosition.top,
        onTap: onTap,
        showProgressBar: showProgressBar,
      ),
    );
  }
}
