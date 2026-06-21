import 'package:flutter/material.dart';

/// Header teal dengan dekorasi lingkaran dan logo BinMart.
/// Dipakai bersama oleh LoginScreen dan RegisterScreen.
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final double height;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.height = 240,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Background gradient ──────────────────────────────────────
          Container(
            height: height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0A7D5A), Color(0xFF0D9E72)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // ── Dekorasi lingkaran besar kanan atas ─────────────────────
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),

          // ── Dekorasi lingkaran kecil kiri atas ──────────────────────
          Positioned(
            top: 20,
            left: -30,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),

          // ── Dekorasi lingkaran kecil kiri bawah ─────────────────────
          Positioned(
            bottom: 30,
            left: 30,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),

          // ── Dekorasi lingkaran kanan bawah ──────────────────────────
          Positioned(
            bottom: -20,
            right: 60,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),

          // ── Konten: logo + teks ──────────────────────────────────────
          Positioned(
            bottom: 36,
            left: 28,
            right: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo inline
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'B',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0D9E72),
                            fontFamily: 'Georgia',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'BinMart',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'BINJAI MARKET',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 5),

                // Subtitle
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
