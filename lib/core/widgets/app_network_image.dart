import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:good_eating/core/constants/app_durations.dart';
import 'package:good_eating/core/theme/app_colors.dart';

/// A cached network image that never shows a broken-image glyph.
///
/// While loading it shows a flat neutral block; if the url is empty or the
/// download fails it shows a neutral block with a plate icon. It fills the
/// space it is given, so clip it with a `ClipRRect` for rounded corners.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    super.key,
  });

  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const _ImageFallback();

    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      fadeInDuration: AppDurations.fast,
      fadeOutDuration: AppDurations.fast,
      placeholder: (context, url) =>
          const ColoredBox(color: AppColors.neutral10),
      errorWidget: (context, url, error) => const _ImageFallback(),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.neutral10,
      child: Center(
        child: Icon(Icons.restaurant_menu_rounded, color: AppColors.neutral30),
      ),
    );
  }
}
