// notification_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

class NotificationWidget extends StatefulWidget {
  final NotificationConfig config;
  final VoidCallback? onDismiss;

  const NotificationWidget({Key? key, required this.config, this.onDismiss})
    : super(key: key);

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _progressController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: widget.config.animationDuration,
      vsync: this,
    );

    _progressController = AnimationController(
      duration: widget.config.duration,
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: widget.config.position == NotificationPosition.top ? -1.0 : 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: widget.config.animationCurve),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.config.animationCurve),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.linear),
    );
  }

  void _startAnimations() {
    _controller.forward();
    if (widget.config.showProgressBar) {
      _progressController.forward();
    }

    // Auto dismiss after duration
    Future.delayed(widget.config.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.config.onDismiss?.call();
    widget.onDismiss?.call();
  }

  Color _getBackgroundColor() {
    if (widget.config.backgroundColor != null) {
      return widget.config.backgroundColor!;
    }

    switch (widget.config.type) {
      case NotificationType.success:
        return Colors.green.shade600;
      case NotificationType.error:
        return Colors.red.shade600;
      case NotificationType.warning:
        return Colors.orange.shade600;
      case NotificationType.info:
        return Colors.blue.shade600;
      case NotificationType.custom:
        return Colors.grey.shade700;
    }
  }

  IconData _getIcon() {
    switch (widget.config.type) {
      case NotificationType.success:
        return Platform.isIOS
            ? CupertinoIcons.check_mark_circled_solid
            : Icons.check_circle;
      case NotificationType.error:
        return Platform.isIOS ? CupertinoIcons.xmark_circle_fill : Icons.error;
      case NotificationType.warning:
        return Platform.isIOS
            ? CupertinoIcons.exclamationmark_triangle_fill
            : Icons.warning;
      case NotificationType.info:
        return Platform.isIOS ? CupertinoIcons.info_circle_fill : Icons.info;
      case NotificationType.custom:
        return Platform.isIOS ? CupertinoIcons.bell_fill : Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 100),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: _buildNotificationContent(),
          ),
        );
      },
    );
  }

  Widget _buildNotificationContent() {
    return Container(
      margin:
          widget.config.margin ??
          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(widget.config.borderRadius ?? 12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.config.onTap,
          borderRadius: BorderRadius.circular(widget.config.borderRadius ?? 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: widget.config.padding ?? const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (widget.config.customIcon != null)
                      widget.config.customIcon!
                    else
                      Icon(
                        _getIcon(),
                        color: widget.config.textColor ?? Colors.white,
                        size: 24,
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.config.title,
                            style: TextStyle(
                              color: widget.config.textColor ?? Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (widget.config.message != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.config.message!,
                              style: TextStyle(
                                color: (widget.config.textColor ?? Colors.white)
                                    .withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (widget.config.dismissible)
                      GestureDetector(
                        onTap: _dismiss,
                        child: Icon(
                          Platform.isIOS ? CupertinoIcons.xmark : Icons.close,
                          color: widget.config.textColor ?? Colors.white,
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ),
              if (widget.config.showProgressBar)
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: _progressAnimation.value,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.8),
                      ),
                      minHeight: 3,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _progressController.dispose();
    super.dispose();
  }
}
