import 'package:flutter/material.dart';

class OnboardingDotIndicator extends StatelessWidget {
  final int currentIndex;
  final int count;
  final Color activeColor;
  final Color inactiveColor;

  const OnboardingDotIndicator({
    super.key,
    required this.currentIndex,
    required this.count,
    this.activeColor = const Color(0xFF0D9E72),
    this.inactiveColor = const Color(0xFFD1D5DB),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
