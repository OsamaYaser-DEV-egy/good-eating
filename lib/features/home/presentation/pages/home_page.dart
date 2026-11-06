import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:good_eating/app/di/injector.dart';
import 'package:good_eating/features/category_meals/presentation/cubit/category_meals_cubit.dart';
import 'package:good_eating/features/home/presentation/cubit/home_feed_cubit.dart';
import 'package:good_eating/features/home/presentation/widgets/home_content.dart';

/// The Home tab. It owns the cubits for its own sections and starts loading
/// them as soon as it is created; the shared category list comes from the
/// app-level `CategoriesCubit`.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<CategoryMealsCubit>()..start()),
        BlocProvider(create: (_) => getIt<HomeFeedCubit>()..load()),
      ],
      child: const HomeContent(),
    );
  }
}
