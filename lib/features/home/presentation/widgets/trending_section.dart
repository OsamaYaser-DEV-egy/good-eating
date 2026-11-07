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
import 'package:good_eating/features/meals/presentation/widgets/meal_trending_card.dart';

/// "Trending now": large cards with a play button, rating and creator.
///
/// "See all" opens the category these meals come from, and appears once that
/// category is known.
class TrendingSection extends StatelessWidget {
  const TrendingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeFeedCubit, DataState<HomeFeed>>(
      builder: (context, state) {
        final category = switch (state) {
          DataSuccess<HomeFeed>(:final data)
              when data.trending.category.isNotEmpty =>
            data.trending.category,
          _ => null,
        };

        return HomeSection(
          title: 'Trending now 🔥',
          onSeeAll: category == null
              ? null
              : () => openCategoryMeals(context, category),
          child: DataStateView<HomeFeed>(
            state: state,
            onRetry: context.read<HomeFeedCubit>().load,
            loadingBuilder: (context) => const _TrendingSkeleton(),
            builder: (context, feed) {
              final meals = feed.trending.meals;
              if (meals.isEmpty) {
                return SectionEmpty(
                  height: MealTrendingCard.heightOf(context),
                  message: 'No trending recipes right now',
                );
              }
              return HorizontalList(
                height: MealTrendingCard.heightOf(context),
                itemCount: meals.length,
                itemBuilder: (context, index) {
                  final meal = meals[index];
                  final heroTag = HeroTags.meal(
                    scope: HeroTags.trending,
                    mealId: meal.id,
                  );
                  return SizedBox(
                    width: MealTrendingCard.carouselWidth,
                    child: MealTrendingCard(
                      meal: meal,
                      heroTag: heroTag,
                      onTap: () => openMealDetails(
                        context,
                        meal: meal,
                        heroTag: heroTag,
                      ),
                    ),
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

class _TrendingSkeleton extends StatelessWidget {
  const _TrendingSkeleton();

  static const int _count = 2;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: HorizontalList(
        height: MealTrendingCard.heightOf(context),
        itemCount: _count,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: _skeletonItem,
      ),
    );
  }

  static Widget _skeletonItem(BuildContext context, int index) =>
      const SizedBox(
        width: MealTrendingCard.carouselWidth,
        child: MealTrendingCardSkeleton(),
      );
}
