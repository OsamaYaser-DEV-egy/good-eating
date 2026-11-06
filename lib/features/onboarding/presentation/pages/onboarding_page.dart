import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:good_eating/app/di/injector.dart';
import 'package:good_eating/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:good_eating/features/onboarding/presentation/widgets/onboarding_view.dart';

/// The welcome screen shown on the very first launch.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OnboardingCubit>(),
      child: const OnboardingView(),
    );
  }
}
