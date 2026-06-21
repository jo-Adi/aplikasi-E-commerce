import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// FCM Service — menangani push notification untuk BinMart
/// - Pembeli: notifikasi status pesanan berubah
/// - Penjual: notifikasi pesanan masuk baru
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handler untuk notifikasi saat app di background/terminated
  debugPrint('FCM Background: ${message.notification?.title}');
}

class FcmService {
  static final _messaging = FirebaseMessaging.instance;

  /// Inisialisasi FCM — dipanggil sekali di main.dart
  static Future<void> initialize() async {
    // 1. Handle background messages
    FirebaseMessaging.onBackgroundMessage(
        firebaseMessagingBackgroundHandler);

    // 2. Request permission (iOS & Web)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint(
        'FCM Permission: ${settings.authorizationStatus}');

    // 3. Handle foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint(
          'FCM Foreground: ${message.notification?.title}');
      // Tampilkan in-app notification banner
      // (dihandle di NotificationBanner widget)
    });

    // 4. Handle tap notifikasi saat app di background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('FCM Opened: ${message.data}');
      // TODO: navigasi ke screen yang relevan berdasarkan data
    });
  }

  /// Simpan FCM token ke Firestore users/{uid}
  /// Dipanggil setelah login berhasil
  static Future<void> saveTokenToFirestore(String uid) async {
    try {
      // Web menggunakan VAPID key — skip jika tidak ada
      String? token;
      if (kIsWeb) {
        // Untuk web, perlu VAPID key dari Firebase Console
        // Settings → Cloud Messaging → Web Push certificates
        // token = await _messaging.getToken(vapidKey: 'YOUR_VAPID_KEY');
        debugPrint('FCM Web: set VAPID key di firebase console');
        return;
      } else {
        token = await _messaging.getToken();
      }

      if (token == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({
        'fcmToken': token,
        'tokenUpdatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('FCM Token saved: $token');
    } catch (e) {
      debugPrint('FCM Token error: $e');
    }
  }

  /// Hapus token saat logout
  static Future<void> deleteToken(String uid) async {
    try {
      await _messaging.deleteToken();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'fcmToken': FieldValue.delete()});
    } catch (e) {
      debugPrint('FCM delete token error: $e');
    }
  }
}
