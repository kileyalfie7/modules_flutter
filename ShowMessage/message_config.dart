
// notification_config.dart
import 'package:flutter/material.dart';

class NotificationConfig {
  final String title;
  final String? message;
  final NotificationType type;
  final NotificationPosition position;
  final Duration duration;
  final bool dismissible;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final Widget? customIcon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool showProgressBar;
  final AnimationCurve animationCurve;
  final Duration animationDuration;

  const NotificationConfig({
    required this.title,
    this.message,
    this.type = NotificationType.info,
    this.position = NotificationPosition.top,
    this.duration = const Duration(seconds: 3),
    this.dismissible = true,
    this.onTap,
    this.onDismiss,
    this.customIcon,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.padding,
    this.margin,
    this.showProgressBar = false,
    this.animationCurve = Curves.easeInOut,
    this.animationDuration = const Duration(milliseconds: 300),
  });
}