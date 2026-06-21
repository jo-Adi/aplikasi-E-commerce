part of 'onboarding_cubit.dart';

class OnboardingState {
  final int currentPage;

  const OnboardingState({required this.currentPage});

  OnboardingState copyWith({int? currentPage}) {
    return OnboardingState(currentPage: currentPage ?? this.currentPage);
  }
}
