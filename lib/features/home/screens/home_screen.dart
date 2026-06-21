import 'package:binmart/features/home/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../profile/screens/profile_screen.dart';
import '../../profile/cubit/profile_cubit.dart';
import '../../../features/notifications/screens/notification_screen.dart';
import '../../../features/auth/cubit/auth_cubit.dart';
import '../../../features/cart/cubit/cart_cubit.dart';
import '../../../features/cart/screens/cart_screen.dart';
import '../../../features/category/screens/category_screen.dart';
import '../../../features/orders/screens/orders_screen.dart';

import '../../../features/onboarding/screens/onboarding_screen.dart';
import '../cubit/home_cubit.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/category_chip.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/product_card.dart';
import '../widgets/promo_banner.dart';

import '../../../features/orders/cubit/order_cubit.dart';
import '../../../features/product/screens/product_detail_screen.dart';
import '../../../features/checkout/screens/checkout_screen.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadHomeData();
    context.read<CartCubit>().loadCart();
    
    // 🟢 MEMANGGIL FUNGSI SETUP FCM SAAT HALAMAN DIBUKA
    _setupPushNotifications();
  }

  // 🟢 FUNGSI BARU: SETUP FCM & MENDAPATKAN TOKEN
 Future<void> _setupPushNotifications() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ Izin notifikasi diberikan!');
      
      String? token = await messaging.getToken();
      if (token != null) {
        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            await FirebaseFirestore.instance
                .collection('users') 
                .doc(user.uid)
                .set({
                  'fcmToken': token,
                  'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
                }, SetOptions(merge: true));
            debugPrint('✅ Token FCM berhasil disimpan!');
          }
        } catch (e) {
          debugPrint('❌ Gagal menyimpan Token: $e');
        }
      }
    }

    // 🟢 Skenario 1: Aplikasi sedang terbuka (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📩 Pesan masuk (Foreground): ${message.notification?.title}');
      
      if (mounted && message.notification != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message.notification!.title ?? 'Notifikasi Baru'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF0D9E72),
          ),
        );
      }
    });

    // 🟢 Skenario 2: Aplikasi terbuka karena notifikasi diklik (Background/Terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('🚀 Notifikasi diklik! Data: ${message.data}');
      
      // Logika navigasi berdasarkan data 'type' yang dikirim dari Firebase Console
      if (message.data['type'] == 'order') {
        Navigator.pushNamed(context, OrdersScreen.routeName);
      } else {
        // Default: Buka halaman notifikasi jika tidak ada tipe spesifik
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onNavTap(BuildContext context, int index, HomeCubit cubit) {
    switch (index) {
      case 0:
        cubit.changeNavIndex(0);
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CategoryScreen()),
        );
        break;
      case 2:
        Navigator.pushNamed(context, CartScreen.routeName);
        break;
      case 3:
        Navigator.pushNamed(context, OrdersScreen.routeName);
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => ProfileCubit()),
                BlocProvider.value(value: context.read<AuthCubit>()),
              ],
              child: ProfileScreen(),
            ),
          ),
        );
        break;
    }
  }

  void _goToDetail(BuildContext context, dynamic product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<CartCubit>()),
            BlocProvider.value(value: context.read<OrderCubit>()),
          ],
          child: ProductDetailScreen(product: product),
        ),
      ),
    );
  }

  void _goToCheckout(BuildContext context, dynamic product) {
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
            directQuantity: 1,      
          ), 
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar dari BinMart?',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827))),
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final cubit = context.read<HomeCubit>();

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                HomeAppBar(
                  userName: state.userName.isEmpty
                      ? 'Pengguna'
                      : state.userName,
                 onNotificationTap: () {
                   Navigator.push(
                 context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
             );
                 },
                  onAvatarTap: () => _showLogoutDialog(context),
                ),
                Expanded(child: _buildBody(context, state, cubit)),
                BlocBuilder<CartCubit, CartState>(
                  builder: (context, cartState) =>
                      BinmartBottomNavBar(
                    currentIndex: state.currentNavIndex,
                    cartItemCount: cartState.totalItems,
                    onTap: (i) => _onNavTap(context, i, cubit),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(
      BuildContext context, HomeState state, HomeCubit cubit) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: HomeSearchBar(
            controller: _searchController,
            onChanged: cubit.updateSearch,
          ),
        ),
        const SliverToBoxAdapter(child: PromoBanner()),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Kategori',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827))),
                GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CategoryScreen())),
                  child: const Text('Lihat Semua',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0D9E72))),
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: SizedBox(
            height: 82,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 20),
              itemCount: binmartCategories.length,
              itemBuilder: (context, i) {
                final cat = binmartCategories[i];
                return CategoryChip(
                  category: cat,
                  isSelected: state.selectedCategory == cat.name,
                  onTap: () => cubit.selectCategory(cat.name),
                );
              },
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  state.selectedCategory ?? 'Produk Pilihan',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827)),
                ),
                const Text('Lihat Semua',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0D9E72))),
              ],
            ),
          ),
        ),

        // Loading
        if (state.loadStatus == HomeLoadStatus.loading)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 60),
              child: Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFF0D9E72))),
            ),
          )

        // Error
        else if (state.loadStatus == HomeLoadStatus.error)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Column(children: [
                const Text('😕', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 12),
                Text(
                  state.errorMessage ?? 'Gagal memuat produk.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: cubit.loadHomeData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9E72),
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: const Text('Coba Lagi'),
                ),
              ]),
            ),
          )

        // Kosong
        else if (state.filteredProducts.isEmpty &&
            state.loadStatus == HomeLoadStatus.loaded)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Column(children: const [
                Text('😔', style: TextStyle(fontSize: 40)),
                SizedBox(height: 12),
                Text('Produk tidak ditemukan',
                    style: TextStyle(
                        fontSize: 14, color: Color(0xFF6B7280))),
              ]),
            ),
          )

        // Grid produk
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final product = state.filteredProducts[i];
                  return ProductCard(
                    product: product,
                    onTap: () => _goToDetail(context, product),
                    onBuyNow: () => _goToCheckout(context, product),
                    onAddToCart: () async {
                      await context
                          .read<CartCubit>()
                          .addToCart(product);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${product.name} ditambahkan ke keranjang'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: const Color(0xFF0D9E72),
                          action: SnackBarAction(
                            label: 'Lihat',
                            textColor: Colors.white,
                            onPressed: () => Navigator.pushNamed(
                                context, CartScreen.routeName),
                          ),
                        ),
                      );
                    },
                  );
                },
                childCount: state.filteredProducts.length,
              ),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.60,
              ),
            ),
          ),
      ],
    );
  }
}