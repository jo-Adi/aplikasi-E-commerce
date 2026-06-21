import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../cubit/seller_cubit.dart';
// Sesuaikan path import StorageService ini dengan struktur folder Anda
import '../../../core/services/storage_service.dart'; 

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _originalPriceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();

  final StorageService _storageService = StorageService();

  String _selectedCategory = 'Kuliner';
  
  // 🟢 Ini yang baru! List untuk menampung FILE gambar fisik, bukan sekadar teks URL
  final List<File> _selectedImages = [];
  bool _isUploading = false; // Indikator tambahan saat foto sedang dikirim ke Firebase

  static const _categories = [
    'Kuliner', 'Buah', 'Fashion',
    'Sembako', 'Elektronik', 'Lainnya'
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _originalPriceCtrl.dispose();
    _stockCtrl.dispose();
    _discountCtrl.dispose();
    super.dispose();
  }

  // 🟢 Fungsi Baru: Membuka Galeri dan memasukkan gambar ke dalam List
  Future<void> _pickImage() async {
    // Batasi maksimal 3 gambar agar UI tidak kepenuhan
    if (_selectedImages.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maksimal 3 foto produk saja.')),
      );
      return;
    }

    final File? imageFile = await _storageService.pickImageFromGallery();
    if (imageFile != null) {
      setState(() {
        _selectedImages.add(imageFile);
      });
    }
  }

  Future<void> _onSave(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap tambahkan minimal 1 foto produk!'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isUploading = true); // Nyalakan loading spinner

    try {
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('Sesi habis, silakan login ulang.');

      // 1. UPLOAD SEMUA GAMBAR KE FIREBASE STORAGE TERLEBIH DAHULU
      List<String> uploadedUrls = [];
      for (var file in _selectedImages) {
        String? downloadUrl = await _storageService.uploadProductImage(file, userId);
        if (downloadUrl != null) {
          uploadedUrls.add(downloadUrl);
        }
        if (!mounted) return;
      }

      if (uploadedUrls.isEmpty) {
        throw Exception('Gagal mengunggah foto. Periksa koneksi internet Anda.');
      }

      // 2. SIMPAN DATA PRODUK + URL GAMBAR KE FIRESTORE
      if (!mounted) return;
      final cubit = context.read<SellerCubit>();
      final price = double.tryParse(_priceCtrl.text.replaceAll('.', '')) ?? 0;
      final originalPrice = double.tryParse(_originalPriceCtrl.text.replaceAll('.', '')) ?? price;
      final stock = int.tryParse(_stockCtrl.text) ?? 0;
      final discount = int.tryParse(_discountCtrl.text);

      final success = await cubit.addProduct(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        price: price,
        originalPrice: originalPrice,
        stock: stock,
        category: _selectedCategory,
        imageUrls: uploadedUrls, // Kirim kumpulan URL yang baru saja didapat dari Firebase Storage
        discountPercent: discount,
      );

      if (!mounted) return;
      setState(() => _isUploading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produk berhasil ditambahkan! 🎉'),
            backgroundColor: Color(0xFF0D9E72),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Gagal menyimpan data ke database.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
            child: const Icon(Icons.arrow_back_rounded, size: 18, color: Color(0xFF374151)),
          ),
        ),
        title: const Text('Tambah Produk',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827))),
      ),
      body: BlocBuilder<SellerCubit, SellerState>(
        builder: (context, state) {
          // Tombol terkunci jika SellerCubit sedang memproses atau foto sedang diunggah
          final isBusy = state.isProcessing || _isUploading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 🟢 AREA PEMILIH FOTO DARI HP ──────────────────────────
                  const Text('Foto Produk',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827))),
                  const SizedBox(height: 6),
                  
                  SizedBox(
                    height: 100,
                    child: Row(
                      children: [
                        // Tombol Tambah Foto
                        GestureDetector(
                          onTap: isBusy ? null : _pickImage,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE1F5EE),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF0D9E72).withValues(alpha: 0.3),
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_rounded, 
                                    color: Color(0xFF0D9E72), size: 28),
                                SizedBox(height: 8),
                                Text('Tambah', 
                                    style: TextStyle(
                                      color: Color(0xFF0D9E72), 
                                      fontSize: 12, 
                                      fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Daftar Preview Foto Fisik yang Dipilih
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedImages.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      image: DecorationImage(
                                        image: FileImage(_selectedImages[index]), // Menampilkan foto dari file lokal HP
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  // Tombol hapus foto dari list preview
                                  Positioned(
                                    top: 4,
                                    right: 16,
                                    child: GestureDetector(
                                      onTap: isBusy 
                                        ? null 
                                        : () => setState(() => _selectedImages.removeAt(index)),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFEF4444),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close, color: Colors.white, size: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── FORM FIELDS DETAIL PRODUK ───────────────────────────
                  _buildField(
                    label: 'Nama Produk',
                    controller: _nameCtrl,
                    hint: 'Contoh: Rambutan Binjai Premium',
                    validator: (v) => v == null || v.trim().isEmpty ? 'Nama tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 14),

                  _buildField(
                    label: 'Deskripsi',
                    controller: _descCtrl,
                    hint: 'Jelaskan produk Anda...',
                    maxLines: 3,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Deskripsi tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 14),

                  const Text('Kategori',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: _inputDecoration('Pilih kategori'),
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v!),
                  ),
                  const SizedBox(height: 14),

                  Row(children: [
                    Expanded(
                      child: _buildField(
                        label: 'Harga Jual (Rp)',
                        controller: _priceCtrl,
                        hint: '25000',
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Wajib diisi';
                          if (double.tryParse(v) == null) return 'Angka saja';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildField(
                        label: 'Harga Normal (Rp)',
                        controller: _originalPriceCtrl,
                        hint: '35000',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 14),

                  Row(children: [
                    Expanded(
                      child: _buildField(
                        label: 'Stok',
                        controller: _stockCtrl,
                        hint: '50',
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Wajib diisi';
                          if (int.tryParse(v) == null) return 'Angka saja';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildField(
                        label: 'Diskon (%)',
                        controller: _discountCtrl,
                        hint: '10 (opsional)',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ]),

                  const SizedBox(height: 28),

                  // Tombol simpan ke Firestore
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isBusy ? null : () => _onSave(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9E72),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: isBusy
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                ),
                                SizedBox(width: 12),
                                Text('Mengunggah...', style: TextStyle(fontWeight: FontWeight.w700))
                              ],
                            )
                          : const Text('Simpan Produk',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151))),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
          decoration: _inputDecoration(hint),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0D9E72), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
    );
  }
}