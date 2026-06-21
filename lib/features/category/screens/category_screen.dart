import 'package:binmart/features/home/models/category_model.dart';
import 'package:flutter/material.dart';

import '../../../core/models/product_model.dart';
import '../../../core/repositories/product_repository.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});
  static const routeName = '/category';

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _productRepo = ProductRepository();
  String _selectedCategory = '';
  List<ProductModel> _products = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = binmartCategories.first.name;
    _loadProducts(_selectedCategory);
  }

  void _loadProducts(String category) {
    setState(() => _loading = true);
    _productRepo.getActiveProducts(category: category).listen((products) {
      if (mounted) setState(() { _products = products; _loading = false; });
    });
  }

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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_rounded,
                size: 18, color: Color(0xFF374151)),
          ),
        ),
        title: const Text('Kategori',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827))),
      ),
      body: Row(
        children: [
          // ── Sidebar kategori ───────────────────────────────────────
          Container(
            width: 90,
            color: Colors.white,
            child: ListView.builder(
              itemCount: binmartCategories.length,
              itemBuilder: (context, i) {
                final cat = binmartCategories[i];
                final isSelected = cat.name == _selectedCategory;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedCategory = cat.name);
                    _loadProducts(cat.name);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE1F5EE)
                          : Colors.white,
                      border: Border(
                        left: BorderSide(
                          color: isSelected
                              ? const Color(0xFF0D9E72)
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(cat.emoji,
                            style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 4),
                        Text(
                          cat.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isSelected
                                ? const Color(0xFF0D9E72)
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Divider
          Container(width: 1, color: const Color(0xFFE5E7EB)),

          // ── Produk grid ─────────────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF0D9E72)))
                : _products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              binmartCategories
                                  .firstWhere((c) =>
                                      c.name == _selectedCategory,
                                      orElse: () => binmartCategories.first)
                                  .emoji,
                              style: const TextStyle(fontSize: 44),
                            ),
                            const SizedBox(height: 12),
                            const Text('Belum ada produk',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280))),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.68,
                        ),
                        itemCount: _products.length,
                        itemBuilder: (context, i) {
                          final p = _products[i];
                          return GestureDetector(
                            onTap: () {},
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: const Color(0xFFE5E7EB)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  // Gambar
                                  Stack(children: [
                                    ClipRRect(
                                      borderRadius:
                                          const BorderRadius.vertical(
                                              top: Radius.circular(14)),
                                      child: p.primaryImage.isNotEmpty
                                          ? Image.network(
                                              p.primaryImage,
                                              height: 100,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_,__,___) =>
                                                  _imgFallback(p),
                                            )
                                          : _imgFallback(p),
                                    ),
                                    if (p.discountPercent != null)
                                      Positioned(
                                        top: 6, left: 6,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEF4444),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: Text(
                                            '-${p.discountPercent}%',
                                            style: const TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                  ]),

                                  // Info
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(p.name,
                                            style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF111827)),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 4),
                                        Text(_formatPrice(p.price),
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF0D9E72))),
                                        const SizedBox(height: 2),
                                        Row(children: [
                                          const Icon(Icons.star_rounded,
                                              size: 11,
                                              color: Color(0xFFF59E0B)),
                                          const SizedBox(width: 2),
                                          Text('${p.rating}',
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xFF6B7280))),
                                        ]),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _imgFallback(ProductModel p) => Container(
        height: 100,
        color: Color(int.parse('FF${p.categoryColorHex}', radix: 16)),
        child: Center(
            child: Text(p.categoryEmoji,
                style: const TextStyle(fontSize: 32))),
      );
}
