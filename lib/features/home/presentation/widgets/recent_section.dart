import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:good_eating/core/state/data_state.dart';
import 'package:good_eating/core/widgets/app_shimmer.dart';
import 'package:good_eating/core/widgets/data_state_view.dart';
import 'package:good_eating/core/widgets/entrance_animation.dart';
import 'package:good_eating/core/widgets/horizontal_list.dart';
import 'package:good_eating/features/category_meals/presentation/category_meals_navigation.dart';
import 'package:good_eating/features/home/presentation/cubit/home_feed.dart';
import 'package:good_eating/features/home/presentation/cubit/home_feed_cubit.dart';
import 'package:good_eating/features/home/presentation/widgets/home_section.dart';
import 'package:good_eating/features/meal_details/presentation/meal_details_navigation.dart';
import 'package:good_eating/features/meals/presentation/hero_tags.dart';
import 'package:good_eating/features/meals/presentation/widgets/meal_recent_card.dart';

/// "Recent recipe": compact photo cards.
///
/// "See all" opens the category these meals come from, and appears once that
/// category is known.
class RecentSection extends StatelessWidget {
  const RecentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeFeedCubit, DataState<HomeFeed>>(
      builder: (context, state) {
        final category = switch (state) {
          DataSuccess<HomeFeed>(:final data)
              when data.recent.category.isNotEmpty =>
            data.recent.category,
          _ => null,
        };

        return HomeSection(
          title: 'Recent recipe',
          onSeeAll: category == null
              ? null
              : () => openCategoryMeals(context, category),
          child: DataStateView<HomeFeed>(
            state: state,
            onRetry: context.read<HomeFeedCubit>().load,
            loadingBuilder: (context) => const _RecentSkeleton(),
            builder: (context, feed) {
              final meals = feed.recent.meals;
              if (meals.isEmpty) {
                return const SectionEmpty(
                  height: MealRecentCard.height,
                  message: 'No recent recipes yet',
                );
              }
              return HorizontalList(
                height: MealRecentCard.height,
                itemCount: meals.length,
                itemBuilder: (context, index) {
                  final meal = meals[index];
                  final heroTag = HeroTags.meal(
                    scope: HeroTags.recent,
                    mealId: meal.id,
                  );
                  return MealRecentCard(
                    meal: meal,
                    heroTag: heroTag,
                    onTap: () =>
                        openMealDetails(context, meal: meal, heroTag: heroTag),
                  ).entrance(index: index);
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _RecentSkeleton extends StatelessWidget {
  const _RecentSkeleton();

  static const int _count = 3;

  @override
  Widget build(BuildContext context) {
    return const AppShimmer(
      child: HorizontalList(
        height: MealRecentCard.height,
        itemCount: _count,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: _skeletonItem,
      ),
    );
  }

  static Widget _skeletonItem(BuildContext context, int index) =>
      const MealRecentCardSkeleton();
}
