import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final ImagePicker _picker = ImagePicker();

  // 1. Fungsi untuk Memilih Gambar dari Galeri
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery, 
        imageQuality: 70, // Kompres sedikit agar upload lebih cepat
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint("🚨 Error picking image: $e");
      return null;
    }
  }

  // 2. Fungsi untuk Upload Foto Produk ke Supabase
  Future<String?> uploadProductImage(File imageFile, String userId) async {
    try {
      final supabase = Supabase.instance.client;
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      await supabase.storage
          .from('product-images')
          .upload(fileName, imageFile, fileOptions: const FileOptions(upsert: true));

      return supabase.storage.from('product-images').getPublicUrl(fileName);
    } catch (e) {
      debugPrint('🚨 ERROR UPLOAD PRODUK: $e'); 
      return null;
    }
  }
  Future<String?> uploadStoreBanner(File imageFile, String storeId) async {
  try {
    final supabase = Supabase.instance.client;
    final String fileName = 'banner_$storeId.jpg';
    // Upload ke bucket 'store-banners' (pastikan bucket sudah dibuat di Supabase)
    await supabase.storage.from('store-banners').upload(fileName, imageFile, fileOptions: const FileOptions(upsert: true));
    return supabase.storage.from('store-banners').getPublicUrl(fileName);
  } catch (e) {
    debugPrint('🚨 ERROR UPLOAD BANNER: $e');
    return null;
  }
}

  // 3. Fungsi untuk Upload Foto Profil ke Supabase
  Future<String?> uploadProfileImage(File imageFile, String userId) async {
    try {
      final supabase = Supabase.instance.client;
      // Gunakan nama file "profile_USERID" agar file lama otomatis tertimpa
      final String fileName = 'profile_$userId.jpg';
      
      await supabase.storage
          .from('profile-images') 
          .upload(fileName, imageFile, fileOptions: const FileOptions(upsert: true));

      return supabase.storage.from('profile-images').getPublicUrl(fileName);
    } catch (e) {
      debugPrint('🚨 ERROR UPLOAD FOTO PROFIL: $e'); 
      return null; 
    }
  }
}