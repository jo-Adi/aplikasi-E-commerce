import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/user_model.dart';
import '../../../features/home/screens/home_screen.dart';
import '../../../features/seller/screens/seller_dashboard_screen.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/auth_text_field.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Fungsi routing berdasarkan role user
  void _navigateByRole(BuildContext context, UserModel user) {
    if (user.role == 'seller') {
      Navigator.pushReplacementNamed(context, SellerDashboardScreen.routeName);
    } else {
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    }
  }

  void _onLogin(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    
    // Memanggil login dengan mengirimkan callback onSuccess
    context.read<AuthCubit>().loginWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          onSuccess: (user) => _navigateByRole(context, user),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthCubit, AuthState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          // KONDISI GAGAL: Munculkan pesan error lewat SnackBar
          if (state.status == AuthStatus.failure) {
            final errorMsg = state.errorMessage ?? 'Terjadi kesalahan saat masuk.';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMsg),
                backgroundColor: const Color(0xFFEF4444),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<AuthCubit>();
          final isLoading = state.status == AuthStatus.loading;

          bool passwordVisible = false;
          try {
            passwordVisible = (state as dynamic).isPasswordVisible ?? false;
          } catch (_) {
            passwordVisible = false;
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // ─── HEADER DENGAN GAMBAR BACKGROUND ──────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 80, left: 24, right: 24, bottom: 60),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: const AssetImage('assets/images/bg_login.jpg'), // Sesuai gambar Anda
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.5), // Efek gelap agar teks putih terbaca
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'B',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0D9E72),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BinMart',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'BINJAI MARKET',
                                style: TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 1.5,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'Masuk',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Selamat datang kembali di BinMart',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                // ─── FORM LOGIN (MENGGUNAKAN WIDGET ASLI ANDA) ───────────────
                Container(
                  // Menarik form putih ke atas agar menimpa gambar background
                  transform: Matrix4.translationValues(0, -30, 0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Masuk ke Akun Anda',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Masuk untuk mulai berbelanja.',
                          style: TextStyle(
                            fontSize: 13, 
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Input Email Asli Anda
                        AuthTextField(
                          hint: 'Email Address',
                          prefixIcon: Icons.mail_outline_rounded,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Email tidak boleh kosong';
                            }
                            if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                              return 'Format email tidak valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Input Password Asli Anda
                        AuthTextField(
                          hint: 'Password',
                          prefixIcon: Icons.lock_outline_rounded,
                          controller: _passwordController,
                          isPassword: true,
                          isPasswordVisible: passwordVisible,
                          onTogglePassword: cubit.togglePasswordVisibility,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Password tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Lupa Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {},
                            child: const Text(
                              'Lupa Password?',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0D9E72),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Tombol Masuk Asli Anda
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : () => _onLogin(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D9E72),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'MASUK',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),

                        // Daftar Sekarang (Tanpa garis dan tombol sosial)
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.pushNamed(context, RegisterScreen.routeName),
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                ),
                                children: [
                                  TextSpan(text: 'Belum punya akun? '),
                                  TextSpan(
                                    text: 'Daftar Sekarang',
                                    style: TextStyle(
                                      color: Color(0xFF0D9E72),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}