import 'package:flutter/material.dart';

import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/widgets/app_shimmer.dart';
import 'package:good_eating/features/meals/domain/entities/meal_category.dart';
import 'package:good_eating/features/meals/presentation/widgets/category_chip.dart';

/// The horizontally scrolling row of category tabs.
class CategoryChipsRow extends StatelessWidget {
  const CategoryChipsRow({
    required this.categories,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<MealCategory> categories;

  /// The active category's name, or null if none is active yet.
  final String? selected;
  final ValueChanged<String> onSelected;

  /// Height of a chip: 12 px text at its natural line height plus 8 px of
  /// padding above and below.
  static const double height = 34;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.screenPadding,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final name = categories[index].name;
          final isLast = index == categories.length - 1;
          return Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : AppSpacing.sm),
            child: CategoryChip(
              label: name,
              selected: name == selected,
              onTap: () => onSelected(name),
            ),
          );
        },
      ),
    );
  }
}

/// Placeholder shown while the categories load.
class CategoryChipsSkeleton extends StatelessWidget {
  const CategoryChipsSkeleton({super.key});

  static const List<double> _widths = [60, 83, 83, 68, 61];

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SizedBox(
        height: CategoryChipsRow.height,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: AppSpacing.screenPadding,
          itemCount: _widths.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ShimmerBox(
              width: _widths[index],
              height: CategoryChipsRow.height,
            ),
          ),
        ),
      ),
    );
  }
}
