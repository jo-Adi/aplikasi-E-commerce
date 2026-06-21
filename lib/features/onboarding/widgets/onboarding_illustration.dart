import 'package:flutter/material.dart';
import '../models/onboarding_data.dart';

class OnboardingIllustrationWidget extends StatefulWidget {
  final OnboardingIllustration type;

  const OnboardingIllustrationWidget({super.key, required this.type});

  @override
  State<OnboardingIllustrationWidget> createState() =>
      _OnboardingIllustrationWidgetState();
}

class _OnboardingIllustrationWidgetState
    extends State<OnboardingIllustrationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnim.value),
          child: SizedBox(
            width: 260,
            height: 240,
            child: CustomPaint(
              painter: _IllustrationPainter(type: widget.type),
            ),
          ),
        );
      },
    );
  }
}

class _IllustrationPainter extends CustomPainter {
  final OnboardingIllustration type;
  const _IllustrationPainter({required this.type});

  static const Color primary = Color(0xFF0D9E72);
  static const Color primaryLight = Color(0xFFE1F5EE);
  static const Color accent = Color(0xFFF97316);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentYellow = Color(0xFFF59E0B);
  static const Color bgCircle = Color(0xFFDEF5EC);
  static const Color white = Colors.white;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final bgPaint = Paint()..color = bgCircle;
    canvas.drawCircle(Offset(cx, cy + 10), 105, bgPaint);

    switch (type) {
      case OnboardingIllustration.shopping:
        _drawShopping(canvas, size, cx, cy);
        break;
      case OnboardingIllustration.payment:
        _drawPayment(canvas, size, cx, cy);
        break;
      case OnboardingIllustration.delivery:
        _drawDelivery(canvas, size, cx, cy);
        break;
    }
  }

  void _drawShopping(Canvas canvas, Size size, double cx, double cy) {
    final phoneRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy - 4), width: 100, height: 148),
      const Radius.circular(18),
    );
    canvas.drawRRect(phoneRect, Paint()..color = const Color(0xFF1A1A2E));

    final screenRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy - 4), width: 88, height: 132),
      const Radius.circular(13),
    );
    canvas.drawRRect(screenRect, Paint()..color = white);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy - 68), width: 22, height: 7),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF1A1A2E),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 44, cy - 64, 88, 22),
        const Radius.circular(0),
      ),
      Paint()..color = primaryLight,
    );
    _drawTextCentered(canvas, 'BinMart', Offset(cx, cy - 53),
        fontSize: 7, color: primary, bold: true);

    _drawShelfRow(canvas, cx, cy - 30, [primary, accent, accentRed]);
    _drawShelfRow(canvas, cx, cy - 8, [accentYellow, primary, const Color(0xFF8B5CF6)]);
    _drawShelfRow(canvas, cx, cy + 14, [accent, accentRed, primary]);
    _drawCartIcon(canvas, Offset(cx, cy + 35), 12);

    _drawFloatingBadge(canvas, Offset(cx - 72, cy - 52), '%', accentYellow);
    _drawFloatingBadgeFull(canvas, Offset(cx + 68, cy - 30), '🛒', primary, '2');
    _drawMiniCart(canvas, Offset(cx + 78, cy + 40));
    _drawLeaf(canvas, Offset(cx - 80, cy + 30));
    _drawPackage(canvas, Offset(cx - 72, cy + 18), 22, accent);
    _drawPackage(canvas, Offset(cx - 55, cy + 38), 18, accentYellow);
    _drawLogoMark(canvas, Offset(cx - 90, cy - 90), 28);
  }

  void _drawPayment(Canvas canvas, Size size, double cx, double cy) {
    final phoneRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy - 4), width: 100, height: 148),
      const Radius.circular(18),
    );
    canvas.drawRRect(phoneRect, Paint()..color = const Color(0xFF1A1A2E));

    final screenRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy - 4), width: 88, height: 132),
      const Radius.circular(13),
    );
    canvas.drawRRect(screenRect, Paint()..color = white);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy - 68), width: 22, height: 7),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF1A1A2E),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy - 20), width: 72, height: 44),
        const Radius.circular(8),
      ),
      Paint()..color = primary,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - 22, cy - 22), width: 14, height: 10),
        const Radius.circular(2),
      ),
      Paint()..color = accentYellow,
    );
    _drawTextCentered(canvas, '**** 4242', Offset(cx, cy - 9),
        fontSize: 7, color: white);
    _drawTextCentered(canvas, 'BinMart Pay', Offset(cx, cy - 34),
        fontSize: 6, color: Color.fromRGBO(255, 255, 255, 0.8));

    _drawWalletIcon(canvas, Offset(cx - 26, cy + 18), 'OVO', const Color(0xFF4C3BCE));
    _drawWalletIcon(canvas, Offset(cx, cy + 18), 'DANA', const Color(0xFF118EEA));
    _drawWalletIcon(canvas, Offset(cx + 26, cy + 18), 'SPY', const Color(0xFFEE4D2D));

    _drawFloatingBadge(canvas, Offset(cx + 68, cy - 50), '✓', primary);
    _drawFloatingBadge(canvas, Offset(cx - 72, cy - 40), 'Rp', accentYellow);
    _drawLeaf(canvas, Offset(cx + 80, cy + 30));
    _drawLogoMark(canvas, Offset(cx - 90, cy - 90), 28);
  }

  void _drawDelivery(Canvas canvas, Size size, double cx, double cy) {
    final phoneRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy - 4), width: 100, height: 148),
      const Radius.circular(18),
    );
    canvas.drawRRect(phoneRect, Paint()..color = const Color(0xFF1A1A2E));

    final screenRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy - 4), width: 88, height: 132),
      const Radius.circular(13),
    );
    canvas.drawRRect(screenRect, Paint()..color = white);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy - 68), width: 22, height: 7),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF1A1A2E),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy - 15), width: 78, height: 80),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFFE8F5E9),
    );

    final roadPaint = Paint()
      ..color = white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx - 39, cy - 15), Offset(cx + 39, cy - 15), roadPaint);
    canvas.drawLine(Offset(cx, cy - 55), Offset(cx, cy + 25), roadPaint);

    _drawPin(canvas, Offset(cx + 14, cy - 28), primary);
    _drawPin(canvas, Offset(cx - 18, cy - 4), accentRed);

    final dotPaint = Paint()
      ..color = primary
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(cx - 18, cy - 4)
      ..cubicTo(cx - 10, cy - 20, cx + 6, cy - 12, cx + 14, cy - 28);
    canvas.drawPath(path, dotPaint);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 44, cy + 26, 88, 16),
        const Radius.circular(0),
      ),
      Paint()..color = primaryLight,
    );
    _drawTextCentered(canvas, 'Sedang Dikirim...', Offset(cx, cy + 34),
        fontSize: 6, color: primary, bold: true);

    _drawFloatingBadge(canvas, Offset(cx + 70, cy - 40), '🚀', accentYellow);
    _drawPackage(canvas, Offset(cx - 76, cy + 10), 24, accent);
    _drawLeaf(canvas, Offset(cx - 78, cy - 40));
    _drawLogoMark(canvas, Offset(cx - 90, cy - 90), 28);
  }

  void _drawShelfRow(Canvas canvas, double cx, double y, List<Color> colors) {
    final shelfPaint = Paint()..color = const Color(0xFFF3F4F6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, y + 8), width: 74, height: 18),
        const Radius.circular(4),
      ),
      shelfPaint,
    );
    for (int i = 0; i < 3; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(cx - 20 + i * 20.0, y + 5), width: 13, height: 13),
          const Radius.circular(3),
        ),
        Paint()..color = colors[i],
      );
    }
    canvas.drawRect(
      Rect.fromLTWH(cx - 37, y + 15, 74, 2),
      Paint()..color = const Color(0xFFD1D5DB),
    );
  }

  void _drawFloatingBadge(
      Canvas canvas, Offset center, String text, Color color) {
    canvas.drawShadow(
      Path()..addOval(Rect.fromCircle(center: center, radius: 18)),
      Colors.black,
      3,
      false,
    );
    canvas.drawCircle(center, 18, Paint()..color = color);
    _drawTextCentered(canvas, text, center, fontSize: 9, color: white, bold: true);
  }

  void _drawFloatingBadgeFull(
      Canvas canvas, Offset center, String icon, Color color, String count) {
    canvas.drawShadow(
      Path()..addOval(Rect.fromCircle(center: center, radius: 18)),
      Colors.black,
      3,
      false,
    );
    canvas.drawCircle(center, 18, Paint()..color = color);
    _drawTextCentered(canvas, icon, center, fontSize: 13, color: white);
    canvas.drawCircle(
        Offset(center.dx + 10, center.dy - 10), 8, Paint()..color = accentRed);
    _drawTextCentered(canvas, count, Offset(center.dx + 10, center.dy - 10),
        fontSize: 7, color: white, bold: true);
  }

  void _drawMiniCart(Canvas canvas, Offset pos) {
    final p = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(pos.dx - 16, pos.dy - 10)
      ..lineTo(pos.dx - 10, pos.dy - 10)
      ..lineTo(pos.dx - 6, pos.dy + 4)
      ..lineTo(pos.dx + 12, pos.dy + 4)
      ..lineTo(pos.dx + 14, pos.dy - 4);
    canvas.drawPath(path, p);
    canvas.drawCircle(
        Offset(pos.dx - 4, pos.dy + 8), 3, Paint()..color = const Color(0xFFD1D5DB));
    canvas.drawCircle(
        Offset(pos.dx + 10, pos.dy + 8), 3, Paint()..color = const Color(0xFFD1D5DB));
  }

  void _drawPackage(Canvas canvas, Offset pos, double size, Color color) {
    canvas.drawShadow(
      Path()
        ..addRRect(RRect.fromRectAndRadius(
          Rect.fromCenter(center: pos, width: size, height: size * 0.85),
          const Radius.circular(4),
        )),
      Colors.black,
      4,
      false,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: pos, width: size, height: size * 0.85),
        const Radius.circular(4),
      ),
      Paint()..color = color,
    );
    canvas.drawRect(
      Rect.fromCenter(center: pos, width: size, height: 3),
      Paint()..color = const Color.fromRGBO(255, 255, 255, 0.4),
    );
  }

  void _drawLeaf(Canvas canvas, Offset pos) {
    final p = Paint()..color = const Color(0xFF34D399);
    final path1 = Path()
      ..moveTo(pos.dx, pos.dy)
      ..quadraticBezierTo(pos.dx + 14, pos.dy - 20, pos.dx + 20, pos.dy - 10)
      ..quadraticBezierTo(pos.dx + 10, pos.dy - 2, pos.dx, pos.dy);
    canvas.drawPath(path1, p);
    final path2 = Path()
      ..moveTo(pos.dx, pos.dy)
      ..quadraticBezierTo(pos.dx - 12, pos.dy - 18, pos.dx - 18, pos.dy - 8)
      ..quadraticBezierTo(pos.dx - 8, pos.dy, pos.dx, pos.dy);
    canvas.drawPath(path2, Paint()..color = const Color(0xFF10B981));
    canvas.drawLine(
      pos,
      Offset(pos.dx, pos.dy + 12),
      Paint()
        ..color = const Color(0xFF6EE7B7)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawWalletIcon(Canvas canvas, Offset pos, String label, Color color) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: pos, width: 34, height: 20),
        const Radius.circular(5),
      ),
      Paint()..color = color,
    );
    _drawTextCentered(canvas, label, pos, fontSize: 5.5, color: white, bold: true);
  }

  void _drawPin(Canvas canvas, Offset pos, Color color) {
    final p = Paint()..color = color;
    canvas.drawCircle(pos, 5, p);
    canvas.drawCircle(pos, 3, Paint()..color = white);
    final path = Path()
      ..moveTo(pos.dx - 3, pos.dy + 3)
      ..lineTo(pos.dx + 3, pos.dy + 3)
      ..lineTo(pos.dx, pos.dy + 10);
    canvas.drawPath(path, p);
  }

  void _drawCartIcon(Canvas canvas, Offset pos, double s) {
    final p = Paint()
      ..color = primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        Offset(pos.dx - s * 0.8, pos.dy - s * 0.3),
        Offset(pos.dx - s * 0.3, pos.dy - s * 0.3), p);
    canvas.drawLine(
        Offset(pos.dx - s * 0.3, pos.dy - s * 0.3),
        Offset(pos.dx + s * 0.2, pos.dy + s * 0.3), p);
    canvas.drawLine(
        Offset(pos.dx + s * 0.2, pos.dy + s * 0.3),
        Offset(pos.dx + s * 0.7, pos.dy + s * 0.3), p);
    canvas.drawCircle(Offset(pos.dx + s * 0.0, pos.dy + s * 0.7), s * 0.22,
        Paint()..color = primary);
    canvas.drawCircle(Offset(pos.dx + s * 0.5, pos.dy + s * 0.7), s * 0.22,
        Paint()..color = primary);
  }

  // Fix: hapus const karena size adalah runtime value
  void _drawLogoMark(Canvas canvas, Offset pos, double size) {
    final radius = Radius.circular(size * 0.28);
    canvas.drawShadow(
      Path()
        ..addRRect(RRect.fromRectAndRadius(
          Rect.fromCenter(center: pos, width: size, height: size),
          radius,
        )),
      Colors.black,
      4,
      false,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: pos, width: size, height: size),
        radius,
      ),
      Paint()..color = primary,
    );
    _drawTextCentered(canvas, 'B', pos,
        fontSize: size * 0.55, color: white, bold: true);
  }

  void _drawTextCentered(
    Canvas canvas,
    String text,
    Offset center, {
    double fontSize = 10,
    Color color = Colors.white,
    bool bold = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _IllustrationPainter old) => old.type != type;
}
