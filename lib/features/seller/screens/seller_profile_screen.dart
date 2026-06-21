import 'package:binmart/core/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/models/user_model.dart';
import '../../../core/models/store_model.dart';
import '../../../core/repositories/user_repository.dart';
import '../../../core/repositories/store_repository.dart';
import '../../../features/auth/cubit/auth_cubit.dart';
import '../../../features/onboarding/screens/onboarding_screen.dart';

class SellerProfileScreen extends StatefulWidget {
  const SellerProfileScreen({super.key});

  @override
  State<SellerProfileScreen> createState() =>
      _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  final _userRepo = UserRepository();
  final _storeRepo = StoreRepository();

  UserModel? _user;
  StoreModel? _store;
  bool _loading = true;
  bool _uploadingAvatar = false;
  bool _uploadingBanner = false;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final uid = _uid;
    if (uid == null) return;
    final user = await _userRepo.getUser(uid);
    final store = await _storeRepo.getStore(uid);
    if (mounted) {
      setState(() {
        _user = user;
        _store = store;
        _loading = false;
      });
    }
  }

  // ── Upload foto profil ────────────────────────────────────────────────────
  Future<void> _uploadAvatar() async {
    final uid = _uid;
    if (uid == null) return;
    
    // Gunakan StorageService kita
    final file = await StorageService().pickImageFromGallery();
    if (file == null) return;

    setState(() => _uploadingAvatar = true);
    
    // Upload ke Supabase
    final url = await StorageService().uploadProfileImage(file, uid);
    
    if (url != null) {
      await _userRepo.updateUser(uid, {'photoUrl': url});
      await FirebaseAuth.instance.currentUser?.updatePhotoURL(url);
      if (mounted) setState(() { _user = _user?.copyWith(photoUrl: url); });
    }
    setState(() => _uploadingAvatar = false);
  }

  // ── Upload banner toko ───────────────────────────────────────────────────
 Future<void> _uploadBanner() async {
    final uid = _uid;
    if (uid == null) return;

    final file = await StorageService().pickImageFromGallery();
    if (file == null) return;

    setState(() => _uploadingBanner = true);
    
    // Upload Banner ke Supabase
    final url = await StorageService().uploadStoreBanner(file, uid);
    
    if (url != null) {
      await _storeRepo.updateStore(uid, {'bannerUrl': url});
      _loadData(); // Refresh data setelah update
    }
    setState(() => _uploadingBanner = false);
  }

  // ── Edit field dialog ────────────────────────────────────────────────────
  void _showEditDialog({
    required String title,
    required String currentValue,
    required Future<void> Function(String) onSave,
    int maxLines = 1,
  }) {
    final ctrl = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text('Edit $title',
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w800)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: title,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: Color(0xFF0D9E72), width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal',
                style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await onSave(ctrl.text.trim());
              await _loadData();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$title berhasil diupdate!'),
                  backgroundColor: const Color(0xFF0D9E72),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9E72),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Simpan',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator(
                color: Color(0xFF0D9E72))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar dengan banner toko ──────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFF0D9E72),
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Banner toko
                  GestureDetector(
                    onTap: _uploadBanner,
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: const Color(0xFF0A7D5A),
                      child: _store?.bannerUrl != null
                          ? Image.network(
                              _store!.bannerUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _bannerFallback(),
                            )
                          : _bannerFallback(),
                    ),
                  ),

                  // Overlay gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                  ),

                  // Edit banner hint
                  if (_uploadingBanner)
                    const Center(
                      child: CircularProgressIndicator(
                          color: Colors.white),
                    )
                  else
                    Positioned(
                      top: 50,
                      right: 16,
                      child: GestureDetector(
                        onTap: _uploadBanner,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color:
                                Colors.black.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.camera_alt_rounded,
                                  color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text('Edit Banner',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Avatar + nama toko di bawah
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Row(
                      children: [
                        // Avatar penjual
                        GestureDetector(
                          onTap: _uploadAvatar,
                          child: Stack(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2.5),
                                ),
                                child: ClipOval(
                                  child: _uploadingAvatar
                                      ? const CircularProgressIndicator(
                                          color: Colors.white)
                                      : _user?.photoUrl != null
                                          ? Image.network(
                                              _user!.photoUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  _avatarFallback(),
                                            )
                                          : _avatarFallback(),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                      Icons.camera_alt_rounded,
                                      size: 11,
                                      color: Color(0xFF0D9E72)),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _store?.storeName ?? 'Toko Saya',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.verified_rounded,
                                    size: 12,
                                    color: _store?.isVerified == true
                                        ? Colors.amber
                                        : Colors.white54,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _store?.isVerified == true
                                        ? 'Terverifikasi'
                                        : 'Belum Terverifikasi',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.white70),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Tombol buka/tutup toko
                        GestureDetector(
                          onTap: () async {
                            final uid = _uid;
                            if (uid == null) return;
                            final newStatus =
                                !(_store?.isOpen ?? true);
                            await _storeRepo.toggleStoreOpen(
                                uid, newStatus);
                            await _loadData();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: (_store?.isOpen ?? true)
                                  ? const Color(0xFF0D9E72)
                                  : const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.white, width: 1.5),
                            ),
                            child: Text(
                              (_store?.isOpen ?? true)
                                  ? '● Buka'
                                  : '● Tutup',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Konten profil ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistik toko mini
                  Row(
                    children: [
                      _MiniStat(
                          label: 'Rating',
                          value:
                              '${_store?.rating.toStringAsFixed(1) ?? '0.0'} ⭐'),
                      _MiniStat(
                          label: 'Terjual',
                          value: '${_store?.totalSales ?? 0}'),
                      _MiniStat(
                          label: 'Kategori',
                          value: _store?.category ?? '-'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Info toko
                  _SectionCard(
                    title: 'Informasi Toko',
                    children: [
                      _InfoTile(
                        icon: Icons.storefront_outlined,
                        label: 'Nama Toko',
                        value: _store?.storeName ?? '-',
                        onEdit: () => _showEditDialog(
                          title: 'Nama Toko',
                          currentValue: _store?.storeName ?? '',
                          onSave: (val) => _storeRepo.updateStore(
                              _uid!, {'storeName': val}),
                        ),
                      ),
                      _InfoTile(
                        icon: Icons.description_outlined,
                        label: 'Deskripsi Toko',
                        value: _store?.description ?? '-',
                        onEdit: () => _showEditDialog(
                          title: 'Deskripsi Toko',
                          currentValue: _store?.description ?? '',
                          maxLines: 3,
                          onSave: (val) => _storeRepo.updateStore(
                              _uid!, {'description': val}),
                        ),
                      ),
                      _InfoTile(
                        icon: Icons.category_outlined,
                        label: 'Kategori Utama',
                        value: _store?.category ?? '-',
                        onEdit: () => _showCategoryPicker(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Info akun pribadi
                  _SectionCard(
                    title: 'Informasi Akun',
                    children: [
                      _InfoTile(
                        icon: Icons.person_outline_rounded,
                        label: 'Nama Lengkap',
                        value: _user?.fullName ?? '-',
                        onEdit: () => _showEditDialog(
                          title: 'Nama Lengkap',
                          currentValue: _user?.fullName ?? '',
                          onSave: (val) async {
                            await _userRepo.updateUser(
                                _uid!, {'fullName': val});
                            await FirebaseAuth.instance.currentUser
                                ?.updateDisplayName(val);
                          },
                        ),
                      ),
                      _InfoTile(
                        icon: Icons.mail_outline_rounded,
                        label: 'Email',
                        value: _user?.email ?? '-',
                        onEdit: null,
                      ),
                      _InfoTile(
                        icon: Icons.phone_outlined,
                        label: 'Nomor Telepon',
                        value:
                            _user?.phoneNumber ?? 'Belum diisi',
                        onEdit: () => _showEditDialog(
                          title: 'Nomor Telepon',
                          currentValue: _user?.phoneNumber ?? '',
                          onSave: (val) => _userRepo.updateUser(
                              _uid!, {'phoneNumber': val}),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Logout
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogoutDialog(),
                      icon: const Icon(Icons.logout_rounded,
                          size: 18, color: Color(0xFFEF4444)),
                      label: const Text(
                        'Keluar dari Akun',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Color(0xFFEF4444)),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'BinMart v1.0.0 · Binjai Market',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryPicker() {
    const categories = [
      'Kuliner', 'Buah', 'Fashion',
      'Sembako', 'Elektronik', 'Lainnya'
    ];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pilih Kategori Utama',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: categories.map((cat) {
                final isSelected = _store?.category == cat;
                return GestureDetector(
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _storeRepo.updateStore(
                        _uid!, {'category': cat});
                    await _loadData();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF0D9E72)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF374151),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar dari BinMart?',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w800)),
        content: const Text('Anda akan keluar dari akun ini.',
            style:
                TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
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

  Widget _bannerFallback() => Container(
        color: const Color(0xFF0A7D5A),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined,
                  color: Colors.white54, size: 32),
              SizedBox(height: 6),
              Text('Tap untuk tambah banner toko',
                  style: TextStyle(
                      color: Colors.white54, fontSize: 12)),
            ],
          ),
        ),
      );

  Widget _avatarFallback() {
    final name = _user?.fullName ?? 'P';
    final initials = name.trim().split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .take(2)
        .join()
        .toUpperCase();
    return Container(
      color: const Color(0xFF0D9E72),
      child: Center(
        child: Text(initials,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700)),
      ),
    );
  }
}

// ── Helper Widgets ──────────────────────────────────────────────────────────

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827))),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: Color(0xFF9CA3AF))),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard(
      {required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(title,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                    letterSpacing: 0.5)),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          ...children,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onEdit;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading:
          Icon(icon, size: 20, color: const Color(0xFF6B7280)),
      title: Text(label,
          style: const TextStyle(
              fontSize: 12, color: Color(0xFF9CA3AF))),
      subtitle: Text(value,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827))),
      trailing: onEdit != null
          ? GestureDetector(
              onTap: onEdit,
              child: const Icon(Icons.edit_outlined,
                  size: 16, color: Color(0xFF0D9E72)),
            )
          : null,
      dense: true,
    );
  }
}
