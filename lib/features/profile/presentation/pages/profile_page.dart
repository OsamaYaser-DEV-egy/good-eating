import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:good_eating/core/state/data_state.dart';
import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/widgets/app_bottom_nav_bar.dart';
import 'package:good_eating/core/widgets/app_empty_view.dart';
import 'package:good_eating/core/widgets/app_error_view.dart';
import 'package:good_eating/core/widgets/page_heading.dart';
import 'package:good_eating/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:good_eating/features/meal_details/presentation/meal_details_navigation.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';
import 'package:good_eating/features/meals/presentation/hero_tags.dart';
import 'package:good_eating/features/profile/presentation/widgets/profile_header.dart';
import 'package:good_eating/features/profile/presentation/widgets/profile_recipe_card.dart';
import 'package:good_eating/features/profile/presentation/widgets/profile_stats.dart';

/// The Profile tab: who the user is, their counts, and their recipes.
///
/// There are no accounts in TheMealDB, so the person is a fixed example from
/// the design. The recipes below are real: they are the meals the user has
/// saved, and the "Recipe" count above them is how many there are.
///
/// The design also draws "Video" and "Recipe" tabs between the counts and the
/// cards. They are left out for the same reason as on the Saved tab: there is
/// nothing to tell the two apart, so they would do nothing.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  /// Gap between the divider and the first card, and between cards.
  static const double _gap = AppSpacing.lg;
  static const double _emptyHeight = 240;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: BlocBuilder<FavoritesCubit, DataState<List<MealSummary>>>(
        builder: (context, state) {
          final cubit = context.read<FavoritesCubit>();
          final recipeCount = switch (state) {
            DataSuccess(:final data) => '${data.length}',
            _ => '–',
          };

          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: PageHeading(title: 'My profile')),
              const SliverToBoxAdapter(child: ProfileHeader()),
              SliverToBoxAdapter(child: ProfileStats(recipeCount: recipeCount)),
              const SliverToBoxAdapter(child: SizedBox(height: _gap)),
              ..._recipes(context, state, cubit),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: AppBottomNavBar.heightOf(context) + AppSpacing.md,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _recipes(
    BuildContext context,
    DataState<List<MealSummary>> state,
    FavoritesCubit cubit,
  ) {
    return switch (state) {
      DataInitial() || DataLoading() => [
        const SliverPadding(
          padding: AppSpacing.screenPadding,
          sliver: SliverToBoxAdapter(child: ProfileRecipeCardSkeleton()),
        ),
      ],
      DataFailure(:final failure) => [
        SliverToBoxAdapter(
          child: AppInlineError(failure: failure, onRetry: cubit.load),
        ),
      ],
      DataSuccess(:final data) when data.isEmpty => const [
        SliverToBoxAdapter(
          child: SizedBox(
            height: _emptyHeight,
            child: AppEmptyView(
              icon: Icons.restaurant_menu_rounded,
              title: 'No recipes yet',
              message: 'Recipes you save with the heart show up here.',
            ),
          ),
        ),
      ],
      DataSuccess(:final data) => [
        SliverPadding(
          padding: AppSpacing.screenPadding,
          sliver: SliverList.separated(
            itemCount: data.length,
            separatorBuilder: (context, index) => const SizedBox(height: _gap),
            itemBuilder: (context, index) {
              final meal = data[index];
              final heroTag = HeroTags.meal(
                scope: HeroTags.profile,
                mealId: meal.id,
              );
              return ProfileRecipeCard(
                key: ValueKey(meal.id),
                meal: meal,
                heroTag: heroTag,
                onTap: () =>
                    openMealDetails(context, meal: meal, heroTag: heroTag),
              );
            },
          ),
        ),
      ],
    };
  }
}
