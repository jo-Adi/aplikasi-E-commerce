import 'package:flutter/material.dart';
import '../../../core/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow; // <-- TAMBAHAN: Parameter Beli Langsung

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
    required this.onBuyNow, // <-- TAMBAHAN: Wajib diisi saat memanggil ProductCard
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
    final hasDiscount = product.discountPercent != null &&
        product.discountPercent! > 0;

    return GestureDetector(
      onTap: onTap, // navigasi ke ProductDetailScreen
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar produk
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16)),
                  child: product.primaryImage.isNotEmpty
                      ? Image.network(
                          product.primaryImage,
                          height: 110,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          headers: const {  
                            'Referer': 'https://ibb.co/',
                          },
                          loadingBuilder: (ctx, child, progress) {
                            if (progress == null) return child;
                            return _buildPlaceholder(isLoading: true);
                          },
                          errorBuilder: (ctx, e, s) =>
                              _buildPlaceholder(isLoading: false),
                        )
                      : _buildPlaceholder(isLoading: false),
                ),

                // Badge diskon
                if (hasDiscount)
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '-${product.discountPercent}%',
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                  ),

                // Wishlist
                Positioned(
                  top: 6, right: 6,
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                        Icons.favorite_border_rounded,
                        size: 15,
                        color: Color(0xFF9CA3AF)),
                  ),
                ),
              ],
            ),

            // Info produk
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                        height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),

                  // Harga
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatPrice(product.price),
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0D9E72)),
                      ),
                      if (hasDiscount &&
                          product.originalPrice > product.price) ...[
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _formatPrice(product.originalPrice),
                            style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF9CA3AF),
                                decoration: TextDecoration.lineThrough),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Toko
                  Row(children: [
                    const Icon(Icons.storefront_outlined,
                        size: 11, color: Color(0xFF9CA3AF)),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        product.storeName,
                        style: const TextStyle(
                            fontSize: 10, color: Color(0xFF9CA3AF)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 6),

                  // Rating + tombol keranjang & beli
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 13, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 3),
                      Text('${product.rating}',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151))),
                      const Spacer(),
                      
                      // --- TOMBOL KERANJANG BARU ---
                      GestureDetector(
                        onTap: onAddToCart,
                        child: Container(
                          width: 26, height: 26,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF0D9E72)), // Outline Hijau
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                              Icons.add_shopping_cart_rounded,
                              size: 14,
                              color: Color(0xFF0D9E72)),
                        ),
                      ),
                      
                      const SizedBox(width: 6),
                      
                      // --- TOMBOL BELI LANGSUNG ---
                      GestureDetector(
                        onTap: onBuyNow,
                        child: Container(
                          height: 26,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D9E72), // Solid Hijau
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Center(
                            child: Text(
                              'Beli',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder({required bool isLoading}) {
    return Container(
      height: 110,
      width: double.infinity,
      color: Color(int.parse('FF${product.categoryColorHex}', radix: 16)),
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(
                    color: Color(0xFF0D9E72), strokeWidth: 2))
            : Text(product.categoryEmoji,
                style: const TextStyle(fontSize: 36)),
      ),
    );
  }
}