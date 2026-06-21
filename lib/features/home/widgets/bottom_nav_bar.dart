import 'package:binmart/features/orders/cubit/order_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Sesuaikan path import OrderCubit di bawah ini dengan struktur folder project Anda

class BinmartBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int cartItemCount;

  const BinmartBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.cartItemCount = 0,
  });

  static const _items = [
    _NavItem(icon: Icons.home_outlined,          activeIcon: Icons.home_rounded,              label: 'Beranda'),
    _NavItem(icon: Icons.category_outlined,      activeIcon: Icons.category_rounded,          label: 'Kategori'),
    _NavItem(icon: Icons.shopping_cart_outlined, activeIcon: Icons.shopping_cart_rounded,     label: 'Keranjang', isCart: true),
    _NavItem(icon: Icons.receipt_long_outlined,  activeIcon: Icons.receipt_long_rounded,      label: 'Pesanan'),
    _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded,            label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final isActive = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    // 🟢 LOGIKA PEMICU DATA:
                    // Jika tab Pesanan (index 3) ditekan, panggil fungsi loadBuyerOrders
                    if (i == 3) {
                      context.read<OrderCubit>().loadBuyerOrders();
                    }
                    
                    // Jalankan fungsi navigasi asli
                    onTap(i);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              isActive ? item.activeIcon : item.icon,
                              key: ValueKey(isActive),
                              size: 24,
                              color: isActive
                                  ? const Color(0xFF0D9E72)
                                  : const Color(0xFF9CA3AF),
                            ),
                          ),
                          // Badge keranjang
                          if (item.isCart && cartItemCount > 0)
                            Positioned(
                              top: -4,
                              right: -8,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEF4444),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    cartItemCount > 9 ? '9+' : '$cartItemCount',
                                    style: const TextStyle(
                                      fontSize: 8,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                          color: isActive
                              ? const Color(0xFF0D9E72)
                              : const Color(0xFF9CA3AF),
                        ),
                        child: Text(item.label),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isCart;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.isCart = false,
  });
}