import 'package:flutter/material.dart';

import 'package:good_eating/core/theme/app_colors.dart';
import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/theme/app_text_styles.dart';
import 'package:good_eating/core/utils/formatters.dart';
import 'package:good_eating/features/meal_details/presentation/widgets/ingredient_tile.dart';
import 'package:good_eating/features/meals/domain/entities/ingredient.dart';

/// "Ingredients", the number of them, and one grey row each.
class IngredientsSection extends StatelessWidget {
  const IngredientsSection({required this.ingredients, super.key});

  final List<Ingredient> ingredients;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: Text('Ingredients', style: AppTextStyles.h5Bold),
            ),
            Text(
              Formatters.itemCount(ingredients.length),
              style: AppTextStyles.labelRegular.copyWith(
                color: AppColors.neutral40,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        for (var i = 0; i < ingredients.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.md),
          IngredientTile(ingredient: ingredients[i]),
        ],
      ],
    );
  }
}
