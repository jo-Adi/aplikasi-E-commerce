import 'package:flutter/material.dart';
import '../../../core/models/order_model.dart';

class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 12, color: config.textColor),
          const SizedBox(width: 4),
          Text(
            config.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: config.textColor,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _statusConfig(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return _StatusConfig(
          label: 'Menunggu',
          icon: Icons.access_time_rounded,
          bgColor: const Color(0xFFFEF3C7),
          textColor: const Color(0xFFD97706),
        );
      case OrderStatus.paid:
        return _StatusConfig(
          label: 'Dibayar',
          icon: Icons.payment_rounded,
          bgColor: const Color(0xFFDCFCE7),
          textColor: const Color(0xFF16A34A),
        );
      case OrderStatus.processing:
        return _StatusConfig(
          label: 'Diproses',
          icon: Icons.inventory_2_outlined,
          bgColor: const Color(0xFFDBEAFE),
          textColor: const Color(0xFF2563EB),
        );
      case OrderStatus.shipped:
        return _StatusConfig(
          label: 'Dikirim',
          icon: Icons.local_shipping_outlined,
          bgColor: const Color(0xFFEDE9FE),
          textColor: const Color(0xFF7C3AED),
        );
      case OrderStatus.delivered:
        return _StatusConfig(
          label: 'Tiba',
          icon: Icons.check_circle_outline_rounded,
          bgColor: const Color(0xFFDCFCE7),
          textColor: const Color(0xFF16A34A),
        );
      case OrderStatus.completed:
        return _StatusConfig(
          label: 'Selesai',
          icon: Icons.verified_rounded,
          bgColor: const Color(0xFFE1F5EE),
          textColor: const Color(0xFF0D9E72),
        );
      case OrderStatus.cancelled:
        return _StatusConfig(
          label: 'Dibatalkan',
          icon: Icons.cancel_outlined,
          bgColor: const Color(0xFFFEE2E2),
          textColor: const Color(0xFFDC2626),
        );
      case OrderStatus.refunded:
        return _StatusConfig(
          label: 'Dikembalikan',
          icon: Icons.replay_rounded,
          bgColor: const Color(0xFFF3F4F6),
          textColor: const Color(0xFF6B7280),
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color textColor;

  const _StatusConfig({
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.textColor,
  });
}
