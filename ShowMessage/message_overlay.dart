
// notification_overlay.dart
import 'package:flutter/material.dart';

class NotificationOverlay {
  static OverlayEntry? _currentOverlay;
  static final List<OverlayEntry> _overlayQueue = [];

  static void show(
    BuildContext context,
    NotificationConfig config,
  ) {
    // Remove current overlay if exists
    if (_currentOverlay != null) {
      _overlayQueue.add(_currentOverlay!);
      _currentOverlay!.remove();
      _currentOverlay = null;
    }

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: config.position == NotificationPosition.top
            ? MediaQuery.of(context).padding.top + 10
            : null,
        bottom: config.position == NotificationPosition.bottom
            ? MediaQuery.of(context).padding.bottom + 10
            : null,
        left: 0,
        right: 0,
        child: config.position == NotificationPosition.center
            ? Center(
                child: NotificationWidget(
                  config: config,
                  onDismiss: () => _removeOverlay(overlayEntry),
                ),
              )
            : NotificationWidget(
                config: config,
                onDismiss: () => _removeOverlay(overlayEntry),
              ),
      ),
    );

    overlay.insert(overlayEntry);
    _currentOverlay = overlayEntry;
  }

  static void _removeOverlay(OverlayEntry entry) {
    entry.remove();
    if (_currentOverlay == entry) {
      _currentOverlay = null;
    }

    // Show next in queue if exists
    if (_overlayQueue.isNotEmpty) {
      final nextOverlay = _overlayQueue.removeAt(0);
      // Note: This is simplified, in practice you'd want to recreate the overlay
    }
  }

  static void clear() {
    _currentOverlay?.remove();
    _currentOverlay = null;
    for (final overlay in _overlayQueue) {
      overlay.remove();
    }
    _overlayQueue.clear();
  }
}