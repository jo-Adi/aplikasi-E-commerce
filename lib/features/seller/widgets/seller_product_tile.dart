import 'package:flutter/material.dart';
import '../../../core/models/product_model.dart';

class SellerProductTile extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const SellerProductTile({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: product.isActive
              ? const Color(0xFFE5E7EB)
              : const Color(0xFFEF4444).withValues(alpha: 0.3),
        ),
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
            child: product.primaryImage.isNotEmpty
                ? Image.network(
                    product.primaryImage,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imgFallback(),
                  )
                : _imgFallback(),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: product.isActive
                            ? const Color(0xFFE1F5EE)
                            : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.isActive ? 'Aktif' : 'Nonaktif',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: product.isActive
                              ? const Color(0xFF0D9E72)
                              : const Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _formatPrice(product.price),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0D9E72),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Stok: ${product.stock} · Terjual: ${product.soldCount}',
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),

          // Action menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded,
                color: Color(0xFF9CA3AF), size: 20),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            onSelected: (val) {
              if (val == 'edit') onEdit();
              if (val == 'toggle') onToggle();
              if (val == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(children: [
                  Icon(Icons.edit_outlined,
                      size: 16, color: Color(0xFF374151)),
                  SizedBox(width: 10),
                  Text('Edit Produk',
                      style: TextStyle(fontSize: 13)),
                ]),
              ),
              PopupMenuItem(
                value: 'toggle',
                child: Row(children: [
                  Icon(
                    product.isActive
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 16,
                    color: const Color(0xFF374151),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    product.isActive ? 'Nonaktifkan' : 'Aktifkan',
                    style: const TextStyle(fontSize: 13),
                  ),
                ]),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete_outline_rounded,
                      size: 16, color: Color(0xFFEF4444)),
                  SizedBox(width: 10),
                  Text('Hapus',
                      style: TextStyle(
                          fontSize: 13, color: Color(0xFFEF4444))),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imgFallback() => Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFFE1F5EE),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
            child: Text(product.categoryEmoji,
                style: const TextStyle(fontSize: 24))),
      );
}
