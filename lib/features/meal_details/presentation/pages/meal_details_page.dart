import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:good_eating/app/di/injector.dart';
import 'package:good_eating/features/meal_details/presentation/cubit/meal_details_cubit.dart';
import 'package:good_eating/features/meal_details/presentation/meal_details_navigation.dart';
import 'package:good_eating/features/meal_details/presentation/widgets/meal_details_view.dart';

/// One recipe in full, opened by tapping a meal anywhere in the app.
class MealDetailsPage extends StatelessWidget {
  const MealDetailsPage({required this.args, super.key});

  final MealDetailsArgs args;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MealDetailsCubit>(param1: args.mealId)..load(),
      child: MealDetailsView(args: args),
    );
  }
}
