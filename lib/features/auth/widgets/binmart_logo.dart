import 'package:flutter/material.dart';

class BinmartLogo extends StatelessWidget {
  final double size;

  const BinmartLogo({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo mark — "B" di kotak teal
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFF0D9E72),
            borderRadius: BorderRadius.circular(size * 0.28),
          ),
          child: Center(
            child: Text(
              'B',
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.55,
                fontWeight: FontWeight.w900,
                fontFamily: 'Georgia',
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'BinMart',
              style: TextStyle(
                fontSize: size * 0.4,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0D9E72),
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'BINJAI MARKET',
              style: TextStyle(
                fontSize: size * 0.18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF9CA3AF),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
