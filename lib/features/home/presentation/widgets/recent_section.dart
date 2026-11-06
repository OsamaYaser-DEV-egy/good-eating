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
import 'package:good_eating/features/meals/presentation/widgets/meal_recent_card.dart';

/// "Recent recipe": compact photo cards.
class RecentSection extends StatelessWidget {
  const RecentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeSection(
      title: 'Recent recipe',
      child: BlocBuilder<HomeFeedCubit, DataState<HomeFeed>>(
        builder: (context, state) => DataStateView<HomeFeed>(
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
              itemBuilder: (context, index) =>
                  MealRecentCard(meal: meals[index]).entrance(index: index),
            );
          },
        ),
      ),
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
