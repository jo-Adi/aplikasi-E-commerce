import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/product_model.dart';
import '../../../features/cart/cubit/cart_cubit.dart';
import '../../../features/orders/cubit/order_cubit.dart';
import '../../checkout/screens/checkout_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  ProductModel get product => widget.product;

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

  void _increaseQty() {
    if (_quantity < product.stock) setState(() => _quantity++);
  }

  void _decreaseQty() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  Future<void> _addToCart(BuildContext context) async {
    final cubit = context.read<CartCubit>();
    for (int i = 0; i < _quantity; i++) {
      await cubit.addToCart(product);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} ($_quantity) ditambahkan ke keranjang'),
        backgroundColor: const Color(0xFF0D9E72),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  void _buyNow(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<CartCubit>()),
            BlocProvider.value(value: context.read<OrderCubit>()),
          ],
          child: CheckoutScreen(
            directProduct: product,
            directQuantity: _quantity,
            product: null,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: Colors.white,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_rounded, size: 20, color: Color(0xFF374151)),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: PageView.builder(  
                itemCount: product.imageUrls.isEmpty ? 1 : product.imageUrls.length,
                itemBuilder: (context, i) {
                  if (product.imageUrls.isEmpty) return _imgFallback();
                  
                  final url = product.imageUrls[i].trim();
                  
                  // Kembali ke Image.network yang bersih
                  return Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('❌ GAGAL MEMUAT GAMBAR: $error');
                      return _imgFallback();
                    },
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(_formatPrice(product.price), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0D9E72))),
                  const SizedBox(height: 16),
                  const Text('Deskripsi Produk', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(product.description.isEmpty ? 'Tidak ada deskripsi.' : product.description, style: const TextStyle(color: Color(0xFF6B7280))),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Jumlah', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      Row(
                        children: [
                          IconButton(onPressed: _decreaseQty, icon: const Icon(Icons.remove_circle_outline)),
                          Text('$_quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                          IconButton(onPressed: _increaseQty, icon: const Icon(Icons.add_circle_outline)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE5E7EB)))),
        child: Row(
          children: [
            Expanded(child: OutlinedButton(onPressed: () => _addToCart(context), child: const Text('+ Keranjang'))),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: ElevatedButton(onPressed: () => _buyNow(context), child: const Text('Beli Sekarang'))),
          ],
        ),
      ),
    );
  }

  Widget _imgFallback() => Container(
        color: Color(int.parse('FF${product.categoryColorHex}', radix: 16)),
        child: Center(child: Text(product.categoryEmoji, style: const TextStyle(fontSize: 60))),
      );
}