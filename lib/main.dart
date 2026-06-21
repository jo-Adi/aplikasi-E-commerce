import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // 🟢 1. Import FCM ditambahkan

import 'firebase_options.dart';

import 'features/onboarding/onboarding.dart';
import 'features/auth/auth.dart';
import 'features/home/home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/cart/cubit/cart_cubit.dart';
import 'features/cart/screens/cart_screen.dart';

import 'features/orders/cubit/order_cubit.dart';
import 'features/orders/screens/orders_screen.dart'; 

import 'features/seller/screens/seller_dashboard_screen.dart';
import 'features/seller/cubit/seller_cubit.dart'; 

// 🟢 2. Fungsi Background FCM (Wajib di luar class/main)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Inisialisasi Firebase lagi khusus untuk background isolate
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("📩 Pesan masuk saat aplikasi ditutup: ${message.messageId}");
}
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  // 1. Kunci binding agar proses async aman
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  // 2. Inisialisasi Firebase murni
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
   String? token = await FirebaseMessaging.instance.getToken();
   debugPrint("🟢 TOKEN FCM TERBARU: $token");
  // 🟢 TAMBAHKAN INISIALISASI SUPABASE DI SINI
  await Supabase.initialize(
    url: 'https://opwxjvzczmvqrhtyaumu.supabase.co',
    anonKey: 'sb_publishable_whSeHX_vt-lpb0gYWIdZNQ_MuYzNDKR',
  );

  // 3. Daftarkan fungsi background ke Firebase
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const BinMartApp());
}

class BinMartApp extends StatelessWidget {
  const BinMartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(),
        ),

        BlocProvider<HomeCubit>(
          create: (_) => HomeCubit(),
        ),

        BlocProvider<OrderCubit>(
          create: (_) => OrderCubit(),
        ),

        BlocProvider<CartCubit>(
          create: (context) => CartCubit(
            orderCubit: context.read<OrderCubit>(),
          ),
        ),

        BlocProvider<SellerCubit>(
          create: (_) => SellerCubit(),
        ),
      ],
      child: MaterialApp(
        title: 'BinMart',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF0D9E72),
          useMaterial3: true,
        ),
        
        // Memulai rute dari onboarding screen semula
        initialRoute: OnboardingScreen.routeName,
        
        routes: {
          OnboardingScreen.routeName: (_) => const OnboardingScreen(),
          RegisterScreen.routeName: (_) => const RegisterScreen(),
          LoginScreen.routeName: (_) => const LoginScreen(),
          HomeScreen.routeName: (_) => const HomeScreen(),
          CartScreen.routeName: (_) => const CartScreen(),
          OrdersScreen.routeName: (_) => const OrdersScreen(),
          SellerDashboardScreen.routeName: (_) => const SellerDashboardScreen(),
        },
      ),
    );
  }
}