import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:good_eating/app/di/injector.dart';
import 'package:good_eating/core/services/link_launcher.dart';
import 'package:good_eating/core/state/data_state.dart';
import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/widgets/app_error_view.dart';
import 'package:good_eating/core/widgets/data_state_view.dart';
import 'package:good_eating/core/widgets/primary_button.dart';
import 'package:good_eating/core/widgets/screen_header.dart';
import 'package:good_eating/features/favorites/presentation/widgets/meal_favorite_heart.dart';
import 'package:good_eating/features/meal_details/presentation/cubit/meal_details_cubit.dart';
import 'package:good_eating/features/meal_details/presentation/meal_details_navigation.dart';
import 'package:good_eating/features/meal_details/presentation/widgets/creator_profile_row.dart';
import 'package:good_eating/features/meal_details/presentation/widgets/ingredients_section.dart';
import 'package:good_eating/features/meal_details/presentation/widgets/instructions_section.dart';
import 'package:good_eating/features/meal_details/presentation/widgets/meal_details_hero_image.dart';
import 'package:good_eating/features/meal_details/presentation/widgets/meal_details_skeleton.dart';
import 'package:good_eating/features/meal_details/presentation/widgets/meal_info_chips.dart';
import 'package:good_eating/features/meal_details/presentation/widgets/meal_rating_row.dart';
import 'package:good_eating/features/meals/domain/entities/meal_detail.dart';

/// The recipe screen: title, photo, rating, creator, then the ingredients and
/// instructions once they have loaded.
///
/// Everything above the ingredients is known before the request finishes (the
/// name and photo come from the card that was tapped, the rest is derived from
/// the id), so only the lower part shows a skeleton.
class MealDetailsView extends StatelessWidget {
  const MealDetailsView({required this.args, super.key});

  final MealDetailsArgs args;

  /// Gap from the header to the photo, and from the creator to the sections.
  static const double _afterHeader = AppSpacing.md;
  static const double _afterCreator = AppSpacing.xxl + AppSpacing.xs;

  /// Room for the error message and its button when the recipe cannot load.
  static const double _errorHeight = 240;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: AppSpacing.xxl + MediaQuery.paddingOf(context).bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenHeader(
                title: args.name,
                trailing: SizedBox.square(
                  dimension: 48,
                  child: Center(
                    child: MealFavoriteHeart(meal: args.toSummary()),
                  ),
                ),
              ),
              const SizedBox(height: _afterHeader),
              BlocBuilder<MealDetailsCubit, DataState<MealDetail>>(
                builder: (context, state) => Padding(
                  padding: AppSpacing.screenPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MealDetailsHeroImage(
                        heroTag: args.heroTag,
                        thumbUrl: args.thumbUrl,
                        onPlay: _videoUrl(state) == null
                            ? null
                            : () => _openVideo(context, _videoUrl(state)!),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      MealRatingRow(mealId: args.mealId),
                      const SizedBox(height: AppSpacing.lg),
                      CreatorProfileRow(mealId: args.mealId),
                      const SizedBox(height: _afterCreator),
                      DataStateView<MealDetail>(
                        state: state,
                        onRetry: context.read<MealDetailsCubit>().load,
                        loadingBuilder: (context) =>
                            const MealDetailsContentSkeleton(),
                        errorBuilder: (context, failure) => SizedBox(
                          height: _errorHeight,
                          child: AppErrorView(
                            failure: failure,
                            onRetry: context.read<MealDetailsCubit>().load,
                          ),
                        ),
                        builder: (context, meal) => _LoadedContent(meal: meal),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The recipe's video, once it has loaded and if it has one.
  String? _videoUrl(DataState<MealDetail> state) =>
      state is DataSuccess<MealDetail> ? state.data.youtubeUrl : null;
}

class _LoadedContent extends StatelessWidget {
  const _LoadedContent({required this.meal});

  final MealDetail meal;

  @override
  Widget build(BuildContext context) {
    final steps = meal.instructionSteps;
    final videoUrl = meal.youtubeUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MealInfoChips(area: meal.area, category: meal.category),
        if (meal.ingredients.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxl),
          IngredientsSection(ingredients: meal.ingredients),
        ],
        if (steps.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxl),
          InstructionsSection(steps: steps),
        ],
        if (videoUrl != null) ...[
          const SizedBox(height: AppSpacing.xxl),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: 'Watch on YouTube',
              icon: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => _openVideo(context, videoUrl),
            ),
          ),
        ],
      ],
    );
  }
}

/// Opens [url] outside the app, and says so if nothing could open it.
Future<void> _openVideo(BuildContext context, String url) async {
  final messenger = ScaffoldMessenger.of(context);
  final opened = await getIt<LinkLauncher>().open(url);
  if (!opened) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Could not open the video.')),
    );
  }
}
