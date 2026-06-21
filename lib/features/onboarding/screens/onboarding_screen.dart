import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/onboarding_cubit.dart';
import '../models/onboarding_data.dart';
import '../widgets/onboarding_dot_indicator.dart';
import '../widgets/onboarding_illustration.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  /// Route name — gunakan ini saat navigasi:
  /// Navigator.pushNamed(context, OnboardingScreen.routeName)
  static const routeName = '/onboarding';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToNext(BuildContext context, OnboardingCubit cubit) {
    if (cubit.isLastPage) {
      // Ganti '/login' dengan route name login screen Anda
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      cubit.nextPage();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(),
      child: BlocBuilder<OnboardingCubit, OnboardingState>(
        builder: (context, state) {
          final cubit = context.read<OnboardingCubit>();

          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  // ── Skip button (top-right) ─────────────────────────────
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12, right: 20),
                      child: GestureDetector(
                        onTap: () =>
                            Navigator.pushReplacementNamed(context, '/login'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE1F5EE),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Lewati',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0D9E72),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Illustration + slide area ───────────────────────────
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: onboardingPages.length,
                      onPageChanged: cubit.changePage,
                      itemBuilder: (context, index) {
                        return _OnboardingPage(data: onboardingPages[index]);
                      },
                    ),
                  ),

                  // ── Bottom section ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    child: Column(
                      children: [
                        // Dots
                        OnboardingDotIndicator(
                          currentIndex: state.currentPage,
                          count: onboardingPages.length,
                        ),

                        const SizedBox(height: 28),

                        // CTA button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () =>
                                _navigateToNext(context, cubit),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D9E72),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  cubit.isLastPage
                                      ? 'MULAI BELANJA'
                                      : 'SELANJUTNYA',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_rounded,
                                    size: 18),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Single page content ─────────────────────────────────────────────────────
class _OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Illustration area with teal rounded card (matches reference style)
          Expanded(
            flex: 6,
            child: Center(
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 340, maxHeight: 300),
                decoration: BoxDecoration(
                  color: const Color(0xFFE1F5EE),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Center(
                  child: OnboardingIllustrationWidget(type: data.illustration),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Title
          Expanded(
            flex: 3,
            child: Column(
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                      color: Color(0xFF111827),
                    ),
                    children: [
                      TextSpan(text: data.title),
                      TextSpan(
                        text: data.titleHighlight,
                        style: const TextStyle(
                          color: Color(0xFF0D9E72),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
