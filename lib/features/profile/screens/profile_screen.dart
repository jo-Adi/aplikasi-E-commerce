import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/auth/cubit/auth_cubit.dart';
import '../../../features/onboarding/screens/onboarding_screen.dart';
import '../cubit/profile_cubit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  static const routeName = '/profile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Warna latar belakang abu-abu terang
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final cubit = context.read<ProfileCubit>();
          final user = state.user;

          return CustomScrollView(
            slivers: [
              // ── HEADER GAYA SHOPEE (ORANGE) ──────────────────────────
              SliverAppBar(
                expandedHeight: 140, // Tinggi proporsional
                pinned: true,
                elevation: 0,
                backgroundColor: const Color(0xFFEE4D2D), // Orange khas Shopee
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFEE4D2D), Color(0xFFFF7337)], // Gradasi Orange
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar (Sangat Diperbesar)
                            GestureDetector(
                              onTap: cubit.uploadProfilePhoto,
                              child: Stack(
                                children: [
                                  Container(
                                    width: 85, // Ukuran diperbesar dari 70 menjadi 85
                                    height: 85,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        )
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: state.isUploadingPhoto
                                          ? const CircularProgressIndicator(color: Colors.white)
                                          : user?.photoUrl != null
                                              ? Image.network(
                                                  user!.photoUrl!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) =>
                                                      _avatarFallback(user.fullName),
                                                )
                                              : _avatarFallback(user?.fullName ?? 'U'),
                                    ),
                                  ),
                                  // Ikon Kamera Kecil
                                  Positioned(
                                    bottom: 0,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: const Color(0xFFEE4D2D), width: 1),
                                      ),
                                      child: const Icon(Icons.camera_alt, size: 14, color: Color(0xFFEE4D2D)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            // Nama Lengkap & Badge
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user?.fullName ?? 'Pengguna',
                                      style: const TextStyle(
                                        fontSize: 20, // Teks nama lebih besar
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    // Badge Member ala Shopee
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.15), // Background transparan elegan
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            user?.role == 'seller' ? Icons.storefront : Icons.stars,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            user?.role == 'seller' ? 'Mitra Penjual' : 'Member Silver',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.chevron_right, size: 14, color: Colors.white),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Ikon Pojok Kanan Atas (Settings & Chat)
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 26),
                                  onPressed: () {},
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                const SizedBox(width: 16),
                                IconButton(
                                  icon: const Icon(Icons.chat_outlined, color: Colors.white, size: 26),
                                  onPressed: () {},
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── KONTEN PROFIL (TETAP SAMA SEPERTI REQUEST ANDA) ──────
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // 1. Kartu "Pesanan Saya"
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      color: Colors.white,
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.receipt_long, color: Color(0xFFEE4D2D)), // Ganti ikon jd orange Shopee
                            title: const Text('Pesanan Saya', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            trailing: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Lihat Riwayat', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                              ],
                            ),
                            onTap: () {},
                          ),
                          const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildOrderShortcut(Icons.account_balance_wallet_outlined, 'Belum Bayar', 2),
                                _buildOrderShortcut(Icons.inventory_2_outlined, 'Dikemas', 0),
                                _buildOrderShortcut(Icons.local_shipping_outlined, 'Dikirim', 1),
                                _buildOrderShortcut(Icons.star_border, 'Beri Penilaian', 0),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 2. Kartu "Dompet & Keuangan"
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildWalletShortcut(Icons.account_balance_wallet, 'BinPay', 'Rp 150.000', const Color(0xFF0D9E72)),
                          Container(width: 1, height: 40, color: Colors.grey.shade300),
                          _buildWalletShortcut(Icons.monetization_on, 'Koin BinMart', '1.200', Colors.amber.shade700),
                          Container(width: 1, height: 40, color: Colors.grey.shade300),
                          _buildWalletShortcut(Icons.local_offer, 'Voucher', '3 Aktif', const Color(0xFFEE4D2D)),
                        ],
                      ),
                    ),

                    // 3. Menu List (Informasi & Pengaturan)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      color: Colors.white,
                      child: Column(
                        children: [
                          _buildMenuTile(
                            icon: Icons.favorite_border,
                            title: 'Favorit Saya',
                            iconColor: const Color(0xFFEE4D2D),
                            onTap: () {},
                          ),
                          _buildMenuTile(
                            icon: Icons.person_outline,
                            title: 'Ubah Data Diri',
                            subtitle: user?.phoneNumber ?? 'Lengkapi profil Anda',
                            iconColor: const Color(0xFF0D9E72),
                            onTap: () => _showEditDialog(context, cubit, 'Nomor Telepon', user?.phoneNumber ?? '', (val) => cubit.updatePhone(val)),
                          ),
                          _buildMenuTile(
                            icon: Icons.location_on_outlined,
                            title: 'Alamat Pengiriman',
                            iconColor: Colors.blue.shade400,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),

                    // 4. Pusat Bantuan & Logout
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 40),
                      color: Colors.white,
                      child: Column(
                        children: [
                          _buildMenuTile(
                            icon: Icons.help_outline,
                            title: 'Pusat Bantuan',
                            iconColor: Colors.orange.shade400,
                            onTap: () {},
                          ),
                          ListTile(
                            leading: const Icon(Icons.logout, color: Colors.red),
                            title: const Text('Keluar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 14)),
                            onTap: () => _showLogoutDialog(context),
                          ),
                        ],
                      ),
                    ),
                    
                    Center(
                      child: Text(
                        'BinMart v1.0.0\nMahasiswa IT Semester 3',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildOrderShortcut(IconData icon, String label, int badgeCount) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, size: 28, color: Colors.grey.shade700),
              if (badgeCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEE4D2D), // Warna badge merah Shopee
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Text(
                      badgeCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
            ],
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildWalletShortcut(IconData icon, String title, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildMenuTile({required IconData icon, required String title, String? subtitle, required Color iconColor, required VoidCallback onTap}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: iconColor),
          title: Text(title, style: const TextStyle(fontSize: 14, color: Colors.black87)),
          subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
          trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
          onTap: onTap,
          dense: true,
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6), indent: 50),
      ],
    );
  }

  Widget _avatarFallback(String name) {
    final initials = name.trim().isEmpty ? 'U' : name.trim().split(' ').map((e) => e[0]).take(2).join();
    return Container(
      color: Colors.grey.shade300,
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: TextStyle(color: Colors.grey.shade700, fontSize: 24, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, ProfileCubit cubit, String fieldName, String currentValue, Future<bool> Function(String) onSave) {
    final ctrl = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ubah $fieldName', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await onSave(ctrl.text.trim());
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Berhasil diperbarui!' : 'Gagal memperbarui.')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEE4D2D)),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthCubit>().logout(
                onSuccess: () => Navigator.pushReplacementNamed(context, OnboardingScreen.routeName),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}