import 'package:flutter/material.dart';
import '../../../core/models/order_model.dart';
import 'order_status_badge.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
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
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final firstItem = order.items.first;
    final extraCount = order.items.length - 1;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
            // Header — nomor order + status
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.orderId.substring(0, 8).toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(order.createdAt),
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF9CA3AF)),
                      ),
                    ],
                  ),
                  OrderStatusBadge(status: order.status),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFE5E7EB)),

            // Item pertama + jumlah item lainnya
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Gambar produk pertama
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: firstItem.imageUrl.isNotEmpty
                        ? Image.network(
                            firstItem.imageUrl,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildImgFallback(),
                          )
                        : _buildImgFallback(),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firstItem.productName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (extraCount > 0) ...[
                          const SizedBox(height: 2),
                          Text(
                            '+$extraCount produk lainnya',
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF6B7280)),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          '${order.items.length} item · ${_formatPrice(order.totalAmount)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0D9E72),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(Icons.chevron_right_rounded,
                      color: Color(0xFF9CA3AF)),
                ],
              ),
            ),

            // Footer action — hanya tampil untuk status tertentu
            if (order.status == OrderStatus.pending ||
                order.status == OrderStatus.processing)
              Container(
                padding:
                    const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (order.status == OrderStatus.pending)
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444),
                          side: const BorderSide(
                              color: Color(0xFFEF4444)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Batalkan',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9E72),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Lihat Detail',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImgFallback() => Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFE1F5EE),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
            child: Text('🛍️', style: TextStyle(fontSize: 22))),
      );
}
