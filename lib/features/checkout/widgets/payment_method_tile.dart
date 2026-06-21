import 'package:flutter/material.dart';

class PaymentMethodData {
  final String id;
  final String name;
  final String subtitle;
  final IconData icon;
  final Color color;

  const PaymentMethodData({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class PaymentMethodTile extends StatelessWidget {
  final dynamic method; // _PaymentMethod from checkout_screen
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodTile({
    super.key,
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? (method.color as Color).withValues(alpha: 0.06)
              : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? method.color as Color
                : const Color(0xFFE5E7EB),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (method.color as Color).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                method.icon as IconData,
                color: method.color as Color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.name as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? method.color as Color
                          : const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    method.subtitle as String,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
            ),

            // Radio indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? method.color as Color
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? method.color as Color
                      : const Color(0xFFD1D5DB),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      size: 13, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
