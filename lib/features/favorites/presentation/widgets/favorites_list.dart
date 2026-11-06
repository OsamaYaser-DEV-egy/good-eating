import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:good_eating/core/theme/app_colors.dart';
import 'package:good_eating/core/theme/app_radii.dart';
import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/widgets/app_bottom_nav_bar.dart';
import 'package:good_eating/core/widgets/app_shimmer.dart';
import 'package:good_eating/core/widgets/entrance_animation.dart';
import 'package:good_eating/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:good_eating/features/meal_details/presentation/meal_details_navigation.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';
import 'package:good_eating/features/meals/presentation/hero_tags.dart';
import 'package:good_eating/features/meals/presentation/widgets/meal_trending_card.dart';

/// The saved meals, newest first, one full-width card each.
///
/// A meal can be removed by tapping its heart or by swiping it away, and
/// either way a snackbar offers to put it back where it was.
class FavoritesList extends StatelessWidget {
  const FavoritesList({required this.meals, super.key});

  final List<MealSummary> meals;

  /// Gap between the heading and the first card, and between cards.
  static const double _top = AppSpacing.lg;
  static const double _gap = AppSpacing.lg;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        _top,
        AppSpacing.screenHorizontal,
        AppBottomNavBar.heightOf(context) + AppSpacing.md,
      ),
      itemCount: meals.length,
      separatorBuilder: (context, index) => const SizedBox(height: _gap),
      itemBuilder: (context, index) {
        final meal = meals[index];
        final heroTag = HeroTags.meal(
          scope: HeroTags.favorites,
          mealId: meal.id,
        );
        return Dismissible(
          key: ValueKey(meal.id),
          direction: DismissDirection.endToStart,
          background: const _RemoveBackground(),
          onDismissed: (_) {
            // Grab these first: the card is gone as soon as it is removed.
            final messenger = ScaffoldMessenger.of(context);
            final cubit = context.read<FavoritesCubit>();
            cubit.remove(meal.id);
            _offerUndo(messenger, cubit, meal, index);
          },
          child: MealTrendingCard(
            meal: meal,
            heroTag: heroTag,
            onTap: () => openMealDetails(context, meal: meal, heroTag: heroTag),
            onFavoriteRemoved: () => _offerUndo(
              ScaffoldMessenger.of(context),
              context.read<FavoritesCubit>(),
              meal,
              index,
            ),
          ).entrance(index: index),
        );
      },
    );
  }

  /// Says the meal was removed and offers to put it back at [index].
  static void _offerUndo(
    ScaffoldMessengerState messenger,
    FavoritesCubit cubit,
    MealSummary meal,
    int index,
  ) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Removed from favorites'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => cubit.insert(meal, index),
          ),
        ),
      );
  }
}

/// What shows behind a card as it is swiped away.
class _RemoveBackground extends StatelessWidget {
  const _RemoveBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.error10,
        borderRadius: AppRadii.lgAll,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.only(right: AppSpacing.xxl),
          child: Icon(Icons.delete_outline_rounded, color: AppColors.error100),
        ),
      ),
    );
  }
}

/// Placeholder shown while the saved meals are read.
class FavoritesListSkeleton extends StatelessWidget {
  const FavoritesListSkeleton({super.key});

  static const int _count = 2;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          FavoritesList._top,
          AppSpacing.screenHorizontal,
          0,
        ),
        itemCount: _count,
        separatorBuilder: (context, index) =>
            const SizedBox(height: FavoritesList._gap),
        itemBuilder: (context, index) => const MealTrendingCardSkeleton(),
      ),
    );
  }
}
