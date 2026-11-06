import 'package:flutter/material.dart';
import 'package:good_eating/core/theme/app_colors.dart';
import 'package:good_eating/core/theme/app_radii.dart';
import 'package:shimmer/shimmer.dart';

/// Sweeps a highlight across [child]. Wrap a whole skeleton in one
/// [AppShimmer] so every block shimmers in sync, and build the skeleton from
/// [ShimmerBox]es.
class AppShimmer extends StatelessWidget {
  const AppShimmer({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.neutral10,
      highlightColor: AppColors.white,
      child: child,
    );
  }
}

/// A solid block used inside an [AppShimmer] to stand in for content.
///
/// It must be painted opaque, because the shimmer only tints what is drawn.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    this.width,
    this.height,
    this.borderRadius = AppRadii.smAll,
    super.key,
  });

  /// A circular block, for avatars.
  const ShimmerBox.circle({required double diameter, super.key})
    : width = diameter,
      height = diameter,
      borderRadius = const BorderRadius.all(Radius.circular(AppRadii.pill));

  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}
