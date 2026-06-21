import 'package:flutter/material.dart';

class SellerNotificationScreen extends StatelessWidget {
  const SellerNotificationScreen({super.key});
  static const routeName = '/seller-notifications';

  @override
  Widget build(BuildContext context) {
    // Data dummy khusus skenario Penjual
    final List<Map<String, String>> sellerNotifications = [
      {
        'title': 'Pesanan Baru Masuk! 🛒',
        'body': 'Ada pesanan baru #BM-9981. Segera proses sebelum batas waktu habis.',
        'time': 'Baru saja',
        'icon': '🔔',
      },
      {
        'title': 'Stok Menipis ⚠️',
        'body': 'Stok produk "Apel Fuji" tersisa 2. Segera tambah stok Anda.',
        'time': '3 jam yang lalu',
        'icon': '📦',
      },
      {
        'title': 'Pencairan Dana Berhasil 💸',
        'body': 'Dana sebesar Rp 250.000 telah masuk ke saldo toko Anda.',
        'time': '1 hari yang lalu',
        'icon': '✅',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
        title: const Text(
          'Notifikasi Toko',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: sellerNotifications.isEmpty
          ? const Center(child: Text('Belum ada notifikasi toko'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sellerNotifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notif = sellerNotifications[index];
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