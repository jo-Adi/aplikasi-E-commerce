import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// In-app notification overlay — muncul sebagai banner di atas screen
/// saat FCM message diterima ketika app sedang aktif (foreground)
class NotificationService {
  static OverlayEntry? _currentEntry;

  /// Setup listener foreground message
  /// Dipanggil sekali di MaterialApp menggunakan navigatorKey
  static void setupForegroundListener(GlobalKey<NavigatorState> navKey) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification == null) return;

      _showBanner(
        navKey: navKey,
        title: notification.title ?? 'BinMart',
        body: notification.body ?? '',
        data: message.data,
      );
    });
  }

  static void _showBanner({
    required GlobalKey<NavigatorState> navKey,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) {
    final context = navKey.currentContext;
    if (context == null) return;

    // Hapus banner sebelumnya
    _currentEntry?.remove();

    _currentEntry = OverlayEntry(
      builder: (_) => _NotificationBanner(
        title: title,
        body: body,
        onDismiss: () {
          _currentEntry?.remove();
          _currentEntry = null;
        },
        onTap: () {
          _currentEntry?.remove();
          _currentEntry = null;
          // TODO: navigasi berdasarkan data['type']
        },
      ),
    );

    Overlay.of(navKey.currentContext!).insert(_currentEntry!);

    // Auto-dismiss setelah 4 detik
    Future.delayed(const Duration(seconds: 4), () {
      _currentEntry?.remove();
      _currentEntry = null;
    });
  }
}

class _NotificationBanner extends StatefulWidget {
  final String title;
  final String body;
  final VoidCallback onDismiss;
  final VoidCallback onTap;

  const _NotificationBanner({
    required this.title,
    required this.body,
    required this.onDismiss,
    required this.onTap,
  });

  @override
  State<_NotificationBanner> createState() =>
      _NotificationBannerState();
}

class _NotificationBannerState extends State<_NotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9E72),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text('🛍️',
                          style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.body,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onDismiss,
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white.withValues(alpha: 0.5),
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
