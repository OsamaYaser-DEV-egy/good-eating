import 'package:flutter/material.dart';

import 'package:good_eating/core/constants/api_constants.dart';
import 'package:good_eating/core/theme/app_colors.dart';
import 'package:good_eating/core/theme/app_radii.dart';
import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/theme/app_text_styles.dart';
import 'package:good_eating/core/widgets/app_network_image.dart';
import 'package:good_eating/features/meals/domain/entities/ingredient.dart';

/// One grey row: the ingredient's picture, its name, and the quantity on the
/// right.
class IngredientTile extends StatelessWidget {
  const IngredientTile({required this.ingredient, super.key});

  final Ingredient ingredient;

  static const double minHeight = 76;
  static const double _iconBox = 52;

  /// Space around the ingredient picture inside its white box.
  static const double _iconPadding = 6;

  /// Keeps a long quantity ("Juice of 1/2 a large lemon") from squeezing the
  /// name out.
  static const double _measureMaxWidth = 110;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: minHeight),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.neutral10,
          borderRadius: AppRadii.mdAll,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              _IngredientIcon(name: ingredient.name),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Text(
                  ingredient.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.paragraphBold,
                ),
              ),
              if (ingredient.measure.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.sm),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _measureMaxWidth),
                  child: Text(
                    ingredient.measure,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.labelRegular.copyWith(
                      color: AppColors.neutral40,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _IngredientIcon extends StatelessWidget {
  const _IngredientIcon({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: AppRadii.controlAll,
        child: ColoredBox(
          color: AppColors.white,
          child: SizedBox.square(
            dimension: IngredientTile._iconBox,
            child: Padding(
              padding: const EdgeInsets.all(IngredientTile._iconPadding),
              child: AppNetworkImage(
                url: ApiConstants.ingredientImageUrl(name),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
