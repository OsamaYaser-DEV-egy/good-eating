import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:good_eating/core/state/data_state.dart';
import 'package:good_eating/core/widgets/app_shimmer.dart';
import 'package:good_eating/core/widgets/data_state_view.dart';
import 'package:good_eating/core/widgets/entrance_animation.dart';
import 'package:good_eating/core/widgets/horizontal_list.dart';
import 'package:good_eating/features/home/presentation/cubit/home_feed.dart';
import 'package:good_eating/features/home/presentation/cubit/home_feed_cubit.dart';
import 'package:good_eating/features/home/presentation/widgets/home_section.dart';
import 'package:good_eating/features/meals/presentation/widgets/meal_trending_card.dart';

/// "Trending now": large cards with a play button, rating and creator.
class TrendingSection extends StatelessWidget {
  const TrendingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeSection(
      title: 'Trending now 🔥',
      child: BlocBuilder<HomeFeedCubit, DataState<HomeFeed>>(
        builder: (context, state) => DataStateView<HomeFeed>(
          state: state,
          onRetry: context.read<HomeFeedCubit>().load,
          loadingBuilder: (context) => const _TrendingSkeleton(),
          builder: (context, feed) {
            final meals = feed.trending.meals;
            if (meals.isEmpty) {
              return const SectionEmpty(
                height: MealTrendingCard.height,
                message: 'No trending recipes right now',
              );
            }
            return HorizontalList(
              height: MealTrendingCard.height,
              itemCount: meals.length,
              itemBuilder: (context, index) =>
                  MealTrendingCard(meal: meals[index]).entrance(index: index),
            );
          },
        ),
      ),
    );
  }
}

class _TrendingSkeleton extends StatelessWidget {
  const _TrendingSkeleton();

  static const int _count = 2;

  @override
  Widget build(BuildContext context) {
    return const AppShimmer(
      child: HorizontalList(
        height: MealTrendingCard.height,
        itemCount: _count,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: _skeletonItem,
      ),
    );
  }

  static Widget _skeletonItem(BuildContext context, int index) =>
      const MealTrendingCardSkeleton();
}
