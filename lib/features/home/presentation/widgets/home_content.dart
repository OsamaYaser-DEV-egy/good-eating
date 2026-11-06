import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:good_eating/core/state/data_state.dart';
import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/widgets/app_bottom_nav_bar.dart';
import 'package:good_eating/core/widgets/app_error_view.dart';
import 'package:good_eating/core/widgets/page_heading.dart';
import 'package:good_eating/features/category_meals/presentation/cubit/category_meals_cubit.dart';
import 'package:good_eating/features/home/presentation/cubit/home_feed_cubit.dart';
import 'package:good_eating/features/home/presentation/widgets/home_search_field.dart';
import 'package:good_eating/features/home/presentation/widgets/popular_category_section.dart';
import 'package:good_eating/features/home/presentation/widgets/popular_creators_section.dart';
import 'package:good_eating/features/home/presentation/widgets/recent_section.dart';
import 'package:good_eating/features/home/presentation/widgets/trending_section.dart';
import 'package:good_eating/features/meals/domain/entities/meal_category.dart';
import 'package:good_eating/features/meals/presentation/cubit/categories_cubit.dart';
import 'package:good_eating/features/shell/presentation/cubit/shell_cubit.dart';
import 'package:good_eating/features/shell/presentation/cubit/shell_tab.dart';

/// The scrolling body of Home.
///
/// If the categories cannot be loaded nothing else can either, so the sections
/// are replaced by a single error with one "Try again" instead of four.
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = AppBottomNavBar.heightOf(context) + AppSpacing.md;

    return SafeArea(
      bottom: false,
      child: BlocBuilder<CategoriesCubit, DataState<List<MealCategory>>>(
        builder: (context, categories) => CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: PageHeading(title: 'Find best recipes\nfor cooking'),
            ),
            SliverToBoxAdapter(
              child: HomeSearchField(
                onTap: () => context.read<ShellCubit>().select(ShellTab.search),
              ),
            ),
            if (categories case DataFailure(:final failure))
              SliverFillRemaining(
                hasScrollBody: false,
                child: AppErrorView(
                  failure: failure,
                  onRetry: () => _reload(context),
                ),
              )
            else
              SliverList.list(
                children: const [
                  TrendingSection(),
                  PopularCategorySection(),
                  RecentSection(),
                  PopularCreatorsSection(),
                ],
              ),
            SliverToBoxAdapter(child: SizedBox(height: bottomPadding)),
          ],
        ),
      ),
    );
  }

  void _reload(BuildContext context) {
    context.read<CategoriesCubit>().load();
    context.read<HomeFeedCubit>().load();
    context.read<CategoryMealsCubit>().start();
  }
}
