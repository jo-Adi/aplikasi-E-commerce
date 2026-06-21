import 'package:flutter/material.dart';
import '../../../core/models/cart_model.dart';

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
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

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.productId),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_rounded,
            color: Colors.white, size: 24),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
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
        child: Row(
          children: [
            // Gambar produk
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: item.imageUrl.isNotEmpty
                  ? Image.network(
                      item.imageUrl,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildImgFallback(),
                    )
                  : _buildImgFallback(),
            ),

            const SizedBox(width: 12),

            // Info produk
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama
                  Text(
                    item.productName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),

                  // Nama toko
                  Text(
                    item.storeName,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF9CA3AF)),
                  ),
                  const SizedBox(height: 8),

                  // Harga + qty control
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Harga subtotal
                      Text(
                        _formatPrice(item.subtotal),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0D9E72),
                        ),
                      ),

                      // Qty control
                      Row(
                        children: [
                          _QtyButton(
                            icon: Icons.remove,
                            onTap: onDecrease,
                            isDecrease: true,
                          ),
                          Container(
                            width: 32,
                            alignment: Alignment.center,
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                          _QtyButton(
                            icon: Icons.add,
                            onTap: onIncrease,
                            isDecrease: false,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImgFallback() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFE1F5EE),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Text('🛍️', style: TextStyle(fontSize: 28)),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDecrease;

  const _QtyButton({
    required this.icon,
    required this.onTap,
    required this.isDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isDecrease
              ? const Color(0xFFF3F4F6)
              : const Color(0xFF0D9E72),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isDecrease
              ? const Color(0xFF374151)
              : Colors.white,
        ),
      ),
    );
  }
}
