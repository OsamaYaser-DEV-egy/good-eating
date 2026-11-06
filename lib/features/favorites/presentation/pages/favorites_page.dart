import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:good_eating/core/state/data_state.dart';
import 'package:good_eating/core/widgets/app_empty_view.dart';
import 'package:good_eating/core/widgets/app_error_view.dart';
import 'package:good_eating/core/widgets/data_state_view.dart';
import 'package:good_eating/core/widgets/page_heading.dart';
import 'package:good_eating/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:good_eating/features/favorites/presentation/widgets/favorites_list.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';
import 'package:good_eating/features/meals/presentation/widgets/meal_card_list_skeleton.dart';

/// The Saved tab: every meal the user has hearted, newest first.
///
/// The design also draws "Video" and "Recipe" tabs above the list. They are
/// left out: a saved meal is just an id, a name and a photo, so there is
/// nothing to tell the two apart, and tabs that show the same list twice
/// would be controls that do nothing.
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      bottom: false,
      child: Column(
        children: [
          PageHeading(title: 'Saved recipes'),
          Expanded(child: _SavedMeals()),
        ],
      ),
    );
  }
}

class _SavedMeals extends StatelessWidget {
  const _SavedMeals();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, DataState<List<MealSummary>>>(
      builder: (context, state) {
        final cubit = context.read<FavoritesCubit>();
        return DataStateView<List<MealSummary>>(
          state: state,
          onRetry: cubit.load,
          loadingBuilder: (context) => const MealCardListSkeleton(),
          errorBuilder: (context, failure) =>
              AppErrorView(failure: failure, onRetry: cubit.load),
          builder: (context, meals) {
            if (meals.isEmpty) {
              return const AppEmptyView(
                icon: Icons.favorite_border_rounded,
                title: 'No saved recipes yet',
                message: 'Tap the heart on any recipe to keep it here.',
              );
            }
            return FavoritesList(meals: meals);
          },
        );
      },
    );
  }
}
