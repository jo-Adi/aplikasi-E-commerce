import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});
  static const routeName = '/notifications';

  @override
  Widget build(BuildContext context) {
    // Data dummy sementara sebelum kita hubungkan ke Firebase/FCM
    final List<Map<String, String>> dummyNotifications = [
      {
        'title': 'Promo Spesial BinMart!',
        'body': 'Dapatkan diskon 50% untuk pembelian buah hari ini.',
        'time': 'Baru saja',
        'icon': '🎉',
      },
      {
        'title': 'Pesanan Sedang Diproses',
        'body': 'Pesanan #BM-1234 sedang disiapkan oleh penjual.',
        'time': '2 jam yang lalu',
        'icon': '📦',
      },
      {
        'title': 'Selamat Datang!',
        'body': 'Terima kasih telah mendaftar di BinMart.',
        'time': '1 hari yang lalu',
        'icon': '👋',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: dummyNotifications.isEmpty
          ? const Center(child: Text('Belum ada notifikasi'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: dummyNotifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notif = dummyNotifications[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notif['icon']!, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notif['title']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notif['body']!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              notif['time']!,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}