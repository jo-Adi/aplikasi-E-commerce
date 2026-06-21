import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/user_model.dart';
import '../../../features/home/screens/home_screen.dart';
import '../../../features/seller/screens/seller_dashboard_screen.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/role_selector.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  static const routeName = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _navigateByRole(BuildContext context, UserModel user) {
    if (user.role == 'seller') {
      Navigator.pushReplacementNamed(context, SellerDashboardScreen.routeName);
    } else {
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    }
  }

  void _onRegister(BuildContext context, AuthCubit cubit, AuthState state) {
    if (!_formKey.currentState!.validate()) return;
    
    // Validasi Checkbox Syarat & Ketentuan dari kode asli Anda
    if (!state.isTermsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap setujui Syarat & Ketentuan.'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    cubit.registerWithEmail(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: state.selectedRole,
      onSuccess: (user) => _navigateByRole(context, user),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthCubit, AuthState>(
        listenWhen: (prev, curr) =>
            curr.status == AuthStatus.failure &&
            prev.status != AuthStatus.failure,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: const Color(0xFFEF4444),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<AuthCubit>();
          final isLoading = state.status == AuthStatus.loading;

          return SingleChildScrollView(
            child: Column(
              children: [
                // ─── HEADER DENGAN GAMBAR BACKGROUND ──────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 60),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: const AssetImage('assets/images/bg_login.jpg'), // Menggunakan gambar yang sama
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.5),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tombol Kembali
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Daftar Baru',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Buat akun dan mulai pengalaman\nterbaik Anda di BinMart.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                // ─── FORM REGISTRASI DENGAN LOGIKA ASLI ANDA ───────────────
                Container(
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
                          'Buat Akun Baru',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Role Selector Asli Anda
                        RoleSelector(
                          selectedRole: state.selectedRole,
                          onRoleSelected: cubit.selectRole,
                        ),
                        const SizedBox(height: 20),

                        // Input Nama
                        AuthTextField(
                          hint: 'Nama Lengkap',
                          prefixIcon: Icons.person_outline_rounded,
                          controller: _nameController,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Nama tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16), // Spasi diperlebar

                        // Input Email
                        AuthTextField(
                          hint: 'Email',
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

                        // Input Password
                        AuthTextField(
                          hint: 'Password',
                          prefixIcon: Icons.lock_outline_rounded,
                          controller: _passwordController,
                          isPassword: true,
                          isPasswordVisible: state.isPasswordVisible,
                          onTogglePassword: cubit.togglePasswordVisibility,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Password tidak boleh kosong';
                            }
                            if (v.length < 8) {
                              return 'Password minimal 8 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Input Konfirmasi Password Asli Anda
                        AuthTextField(
                          hint: 'Konfirmasi Password',
                          prefixIcon: Icons.lock_outline_rounded,
                          controller: _confirmController,
                          isPassword: true,
                          isPasswordVisible: state.isConfirmPasswordVisible,
                          onTogglePassword: cubit.toggleConfirmPasswordVisibility,
                          validator: (v) {
                            if (v != _passwordController.text) {
                              return 'Password tidak cocok';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Checkbox Syarat & Ketentuan Asli Anda
                        GestureDetector(
                          onTap: cubit.toggleTerms,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 20,
                                height: 20,
                                margin: const EdgeInsets.only(top: 1),
                                decoration: BoxDecoration(
                                  color: state.isTermsAccepted
                                      ? const Color(0xFF0D9E72)
                                      : Colors.white,
                                  border: Border.all(
                                    color: state.isTermsAccepted
                                        ? const Color(0xFF0D9E72)
                                        : const Color(0xFFD1D5DB),
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: state.isTermsAccepted
                                    ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: RichText(
                                  text: const TextSpan(
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280),
                                      height: 1.5,
                                    ),
                                    children: [
                                      TextSpan(text: 'Saya menyetujui '),
                                      TextSpan(
                                        text: 'Syarat & Ketentuan',
                                        style: TextStyle(
                                          color: Color(0xFF0D9E72),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(text: ' serta '),
                                      TextSpan(
                                        text: 'Kebijakan Privasi',
                                        style: TextStyle(
                                          color: Color(0xFF0D9E72),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(text: ' BinMart.'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Tombol Daftar
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : () => _onRegister(context, cubit, state),
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
                                    'DAFTAR',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),

                        // Kembali ke Login
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.pushReplacementNamed(context, LoginScreen.routeName),
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                ),
                                children: [
                                  TextSpan(text: 'Sudah memiliki akun? '),
                                  TextSpan(
                                    text: 'Masuk',
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