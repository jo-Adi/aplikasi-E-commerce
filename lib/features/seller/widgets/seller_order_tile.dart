import 'package:flutter/material.dart';
import '../../../core/models/order_model.dart';

class SellerOrderTile extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onProcess;
  final VoidCallback onComplete;

  const SellerOrderTile({
    super.key,
    required this.order,
    required this.onProcess,
    required this.onComplete,
  });

  String _formatPrice(double price) {
    final str = price.toInt().toString();
    final buf = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write('.');
      buf.write(str[i]);
      count++;
    }
    return 'Rp ${buf.toString().split('').reversed.join()}';
  }

  String _formatDate(DateTime date) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month]}, '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return const Color(0xFFD97706);
      case OrderStatus.processing:
        return const Color(0xFF2563EB);
      case OrderStatus.completed:
        return const Color(0xFF0D9E72);
      case OrderStatus.cancelled:
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _statusLabel(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return 'Menunggu';
      case OrderStatus.processing:
        return 'Diproses';
      case OrderStatus.completed:
        return 'Selesai';
      case OrderStatus.cancelled:
        return 'Dibatalkan';
      default:
        return s.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${order.orderId.substring(0, 8).toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${order.buyerName} · ${_formatDate(order.createdAt)}',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _statusLabel(order.status),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // Items summary
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.items
                            .map((i) =>
                                '${i.productName} (${i.quantity}x)')
                            .join(', '),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF374151),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatPrice(order.sellerAmount),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0D9E72),
                        ),
                      ),
                    ],
                  ),
                ),

                // Action buttons
                if (order.status == OrderStatus.pending)
                  ElevatedButton(
                    onPressed: onProcess,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Proses',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ),

                if (order.status == OrderStatus.processing)
                  ElevatedButton(
                    onPressed: onComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9E72),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Selesai',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
