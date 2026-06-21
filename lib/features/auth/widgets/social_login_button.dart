import 'package:flutter/material.dart';

enum SocialProvider { google, facebook }

class SocialLoginButton extends StatelessWidget {
  final SocialProvider provider;
  final VoidCallback onTap;
  final bool isLoading;

  const SocialLoginButton({
    super.key,
    required this.provider,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLogo(),
            const SizedBox(width: 10),
            Text(
              provider == SocialProvider.google ? 'Google' : 'Facebook',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    if (provider == SocialProvider.google) {
      return _GoogleLogo();
    } else {
      return _FacebookLogo();
    }
  }
}

/// Google logo — 4 warna asli menggunakan CustomPainter
class _GoogleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r = size.width / 2;

    // Background circle
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()..color = Colors.white,
    );

    // Clip to circle
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r)));

    // Red (top-left quadrant)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      3.14 * 1.0,
      3.14 * 0.5,
      true,
      Paint()..color = const Color(0xFFEA4335),
    );
    // Blue (top-right)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      3.14 * 1.5,
      3.14 * 0.5,
      true,
      Paint()..color = const Color(0xFF4285F4),
    );
    // Green (bottom-right)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      0,
      3.14 * 0.5,
      true,
      Paint()..color = const Color(0xFF34A853),
    );
    // Yellow (bottom-left)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      3.14 * 0.5,
      3.14 * 0.5,
      true,
      Paint()..color = const Color(0xFFFBBC05),
    );

    // White center
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.55,
      Paint()..color = Colors.white,
    );

    // Blue "G" bar (right side)
    canvas.drawRect(
      Rect.fromLTWH(cx, cy - r * 0.18, r * 0.95, r * 0.36),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Facebook logo — "f" putih di background biru
class _FacebookLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: const Color(0xFF1877F2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Center(
        child: Text(
          'f',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
      ),
    );
  }
}
