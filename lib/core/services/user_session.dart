import 'package:shared_preferences/shared_preferences.dart';

/// UserSession — menyimpan data user sementara di local storage.
/// Tahap 2: akan diganti dengan Firebase Auth currentUser.
class UserSession {
  static const _keyName  = 'user_name';
  static const _keyEmail = 'user_email';
  static const _keyRole  = 'user_role';

  /// Simpan data setelah register / login
  static Future<void> save({
    required String name,
    required String email,
    required String role, // 'buyer' | 'seller'
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyRole, role);
  }

  /// Ambil nama user
  static Future<String> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyName) ?? 'Pengguna';
  }

  /// Ambil email user
  static Future<String> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail) ?? '';
  }

  /// Ambil role user
  static Future<String> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRole) ?? 'buyer';
  }

  /// Hapus semua data (logout)
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyName);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyRole);
  }

  /// Cek apakah user sudah login
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_keyName);
    return name != null && name.isNotEmpty;
  }
}
