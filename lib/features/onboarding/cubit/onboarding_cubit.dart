import 'package:flutter_bloc/flutter_bloc.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(const OnboardingState(currentPage: 0));

  void changePage(int page) {
    emit(state.copyWith(currentPage: page));
  }

  void nextPage() {
    if (state.currentPage < 2) {
      emit(state.copyWith(currentPage: state.currentPage + 1));
    }
  }

  bool get isLastPage => state.currentPage == 2;
}
