class OnboardingData {
  final String title;
  final String titleHighlight;
  final String description;
  final OnboardingIllustration illustration;

  const OnboardingData({
    required this.title,
    required this.titleHighlight,
    required this.description,
    required this.illustration,
  });
}

enum OnboardingIllustration {
  shopping,
  payment,
  delivery,
}

final List<OnboardingData> onboardingPages = [
  const OnboardingData(
    title: 'Welcome to\n',
    titleHighlight: 'Binjai Market 🎉',
    description:
        'Belanja mudah, cepat, dan terpercaya\nuntuk semua kebutuhan sehari-hari.',
    illustration: OnboardingIllustration.shopping,
  ),
  const OnboardingData(
    title: 'Pembayaran\n',
    titleHighlight: 'Aman & Mudah 💳',
    description:
        'Bayar via e-wallet, transfer bank,\natau metode pembayaran favoritmu.',
    illustration: OnboardingIllustration.payment,
  ),
  const OnboardingData(
    title: 'Pengiriman\n',
    titleHighlight: 'Cepat & Terpercaya 🚀',
    description:
        'Lacak pesananmu secara real-time\ndari toko langsung ke tanganmu.',
    illustration: OnboardingIllustration.delivery,
  ),
];
