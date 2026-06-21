import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget {
  final String userName;
  final VoidCallback onNotificationTap;
  final VoidCallback onAvatarTap;

  const HomeAppBar({
    super.key,
    required this.userName,
    required this.onNotificationTap,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        children: [
          // Greeting + nama
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selamat datang 👋',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Notification bell
          GestureDetector(
            onTap: onNotificationTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(
                      Icons.notifications_outlined,
                      size: 22,
                      color: Color(0xFF374151),
                    ),
                  ),
                  // Badge notifikasi
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Avatar
          GestureDetector(
            onTap: onAvatarTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF0D9E72),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  // Ambil inisial dari nama
                  userName.isNotEmpty
                      ? userName.trim().split(' ').map((e) => e[0]).take(2).join()
                      : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
