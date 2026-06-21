import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Ditambahkan untuk mengambil foto profil otomatis

import 'seller_notification_screen.dart';
import '../../../core/models/order_model.dart';
import '../../../features/auth/cubit/auth_cubit.dart';
import '../../../features/onboarding/screens/onboarding_screen.dart';
import '../cubit/seller_cubit.dart';
import '../widgets/seller_stat_card.dart';
import '../widgets/seller_product_tile.dart';
import '../widgets/seller_order_tile.dart';
import 'add_product_screen.dart';
import 'seller_profile_screen.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});
  static const routeName = '/seller';

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<SellerCubit>().loadSellerData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatRevenue(double amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}Jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}Rb';
    }
    return 'Rp ${amount.toInt()}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SellerCubit, SellerState>(
      builder: (context, state) {
        final cubit = context.read<SellerCubit>();
        final storeName = state.store?.storeName ?? 'Toko Saya';
        final bannerUrl = state.store?.bannerUrl;
        
        // Mengambil data user yang sedang login untuk foto profil
        final currentUser = FirebaseAuth.instance.currentUser;
        final photoUrl = currentUser?.photoURL;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5), // Warna Background Baru yang Elegan
          body: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverAppBar(
                expandedHeight: 220, // Diperbesar untuk menampung Banner + TabBar
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF0D9E72),
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // 1. Menampilkan Banner Toko (Atau Gradient Hijau jika belum ada)
                      if (bannerUrl != null && bannerUrl.isNotEmpty)
                        Image.network(bannerUrl, fit: BoxFit.cover)
                      else
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF0A7D5A), Color(0xFF0D9E72)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        
                      // 2. Efek Gelap (Overlay) agar teks putih selalu terbaca
                      Container(color: Colors.black.withOpacity(0.4)),

                      // 3. Konten Header (Profil & Info)
                      Positioned(
                        bottom: 60, // Diberi jarak 60 agar tidak tertimpa TabBar di bawahnya
                        left: 20,
                        right: 20,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Avatar Toko (Sekarang Menampilkan Foto Profil Asli)
                            GestureDetector(
                              onTap: () => _openProfile(context, cubit),
                              child: Container(
                                width: 55,
                                height: 55,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))
                                  ],
                                ),
                                child: ClipOval(
                                  child: photoUrl != null && photoUrl.isNotEmpty
                                      ? Image.network(photoUrl, fit: BoxFit.cover)
                                      : Container(
                                          color: Colors.white.withOpacity(0.2),
                                          child: const Center(child: Text('🏪', style: TextStyle(fontSize: 24))),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Info Toko
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    storeName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          state.store?.isVerified == true ? Icons.verified : Icons.storefront,
                                          size: 12,
                                          color: state.store?.isVerified == true ? Colors.amber : Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          state.store?.isVerified == true ? 'Terverifikasi' : 'Mitra Penjual',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Aksi (Lonceng, Profil, Logout)
                            Row(
                              children: [
                                _buildActionBtn(
                                  icon: Icons.notifications_none_rounded,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const SellerNotificationScreen()),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                _buildActionBtn(
                                  icon: Icons.settings_outlined,
                                  onTap: () => _openProfile(context, cubit),
                                ),
                                const SizedBox(width: 8),
                                _buildActionBtn(
                                  icon: Icons.logout_rounded,
                                  onTap: () => _showLogoutDialog(context),
                                  iconColor: const Color(0xFFFFB4B4),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withOpacity(0.6),
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  tabs: const [
                    Tab(text: 'Dashboard'),
                    Tab(text: 'Produk'),
                    Tab(text: 'Pesanan'),
                  ],
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildDashboardTab(state),
                _buildProductsTab(context, state, cubit),
                _buildOrdersTab(context, state, cubit),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget bantuan untuk merapikan tombol header
  Widget _buildActionBtn({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3), // Diubah ke hitam transparan agar elegan di atas banner
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 19),
      ),
    );
  }

  void _openProfile(BuildContext context, SellerCubit cubit) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<AuthCubit>()),
            BlocProvider.value(value: cubit),
          ],
          child: const SellerProfileScreen(),
        ),
      ),
    );
    // Memuat ulang data saat kembali dari profil (agar banner/foto terupdate)
    cubit.loadSellerData();
  }

  Widget _buildDashboardTab(SellerState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Statistik Toko',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827))),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              SellerStatCard(
                label: 'Total Produk',
                value: '${state.totalProducts}',
                icon: Icons.inventory_2_outlined,
                color: const Color(0xFF2563EB),
              ),
              SellerStatCard(
                label: 'Produk Aktif',
                value: '${state.activeProducts}',
                icon: Icons.check_circle_outline_rounded,
                color: const Color(0xFF0D9E72),
              ),
              SellerStatCard(
                label: 'Total Pesanan',
                value: '${state.totalOrders}',
                icon: Icons.receipt_long_outlined,
                color: const Color(0xFF7C3AED),
              ),
              SellerStatCard(
                label: 'Menunggu',
                value: '${state.pendingOrders}',
                icon: Icons.access_time_rounded,
                color: const Color(0xFFD97706),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Revenue card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0A7D5A), Color(0xFF0D9E72)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D9E72).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Pendapatan',
                    style: TextStyle(fontSize: 13, color: Colors.white70)),
                const SizedBox(height: 6),
                Text(_formatRevenue(state.totalRevenue),
                    style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Colors.white)),
                const SizedBox(height: 4),
                const Text('Dari pesanan selesai',
                    style: TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
          ),

          if (state.orders.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('Pesanan Terbaru',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827))),
            const SizedBox(height: 10),
            ...state.orders.take(3).map((o) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '#${o.orderId.substring(0, 8).toUpperCase()} · ${o.buyerName}',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827)),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: o.status == OrderStatus.pending
                              ? const Color(0xFFFEF3C7)
                              : const Color(0xFFE1F5EE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          o.status == OrderStatus.pending ? 'Baru' : 'Diproses',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: o.status == OrderStatus.pending
                                ? const Color(0xFFD97706)
                                : const Color(0xFF0D9E72),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildProductsTab(
      BuildContext context, SellerState state, SellerCubit cubit) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: cubit,
                    child: const AddProductScreen(),
                  ),
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Tambah Produk Baru',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9E72),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
        Expanded(
          child: state.products.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('📦', style: TextStyle(fontSize: 44)),
                      SizedBox(height: 12),
                      Text('Belum ada produk',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151))),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: state.products.length,
                  itemBuilder: (context, i) {
                    final product = state.products[i];
                    return SellerProductTile(
                      product: product,
                      onEdit: () {},
                      onToggle: () {
                        cubit.toggleProduct(
                            product.productId, !product.isActive);
                      },
                      onDelete: () {
                        _showDeleteDialog(context, cubit, product.productId);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildOrdersTab(
      BuildContext context, SellerState state, SellerCubit cubit) {
    final activeOrders = state.orders
        .where((o) =>
            o.status == OrderStatus.pending ||
            o.status == OrderStatus.processing)
        .toList();
    final doneOrders = state.orders
        .where((o) =>
            o.status == OrderStatus.completed ||
            o.status == OrderStatus.cancelled)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (activeOrders.isNotEmpty) ...[
          const Text('Perlu Ditindak',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827))),
          const SizedBox(height: 10),
          ...activeOrders.map((o) => SellerOrderTile(
                order: o,
                onProcess: () => cubit.processOrder(o.orderId),
                onComplete: () => cubit.completeOrder(o.orderId),
              )),
          const SizedBox(height: 16),
        ],
        if (doneOrders.isNotEmpty) ...[
          const Text('Riwayat',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827))),
          const SizedBox(height: 10),
          ...doneOrders.map((o) => SellerOrderTile(
                order: o,
                onProcess: () {},
                onComplete: () {},
              )),
        ],
        if (state.orders.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 60),
              child: Column(children: [
                Text('📋', style: TextStyle(fontSize: 44)),
                SizedBox(height: 12),
                Text('Belum ada pesanan masuk',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151))),
              ]),
            ),
          ),
      ],
    );
  }

  void _showDeleteDialog(
      BuildContext context, SellerCubit cubit, String productId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Produk?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        content: const Text('Produk akan dihapus permanen.',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal',
                style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              cubit.deleteProduct(productId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hapus',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar dari BinMart?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        content: const Text('Anda akan keluar dari akun ini.',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal',
                style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthCubit>().logout(
                    onSuccess: () => Navigator.pushReplacementNamed(
                        context, OnboardingScreen.routeName),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Keluar',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}