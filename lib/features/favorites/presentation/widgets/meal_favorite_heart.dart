import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:good_eating/core/widgets/favorite_heart_button.dart';
import 'package:good_eating/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';

/// The heart for one meal, wired to the app's saved meals.
///
/// It fills when the meal is saved, wherever it was saved from, and tapping it
/// saves or removes the meal.
class MealFavoriteHeart extends StatelessWidget {
  const MealFavoriteHeart({
    required this.meal,
    this.size = 32,
    this.onRemoved,
    super.key,
  });

  final MealSummary meal;
  final double size;

  /// Called after a tap that removed the meal, for screens that offer to undo.
  final VoidCallback? onRemoved;

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.select<FavoritesCubit, bool>(
      (cubit) => cubit.isFavorite(meal.id),
    );

    return FavoriteHeartButton(
      isFavorite: isFavorite,
      size: size,
      onPressed: () {
        final cubit = context.read<FavoritesCubit>();
        final wasFavorite = cubit.isFavorite(meal.id);
        cubit.toggle(meal);
        if (wasFavorite) onRemoved?.call();
      },
    );
  }
}
