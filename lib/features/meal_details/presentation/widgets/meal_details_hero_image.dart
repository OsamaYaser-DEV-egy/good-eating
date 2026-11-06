import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:good_eating/core/constants/app_assets.dart';
import 'package:good_eating/core/theme/app_radii.dart';
import 'package:good_eating/core/widgets/app_network_image.dart';

/// The meal photo at the top of the details screen. It is the landing spot of
/// the hero animation from whichever card was tapped.
///
/// When [onPlay] is given the photo shows a play button and opens the video
/// when tapped. It is null for recipes without a video, so the screen never
/// promises one it cannot deliver.
class MealDetailsHeroImage extends StatelessWidget {
  const MealDetailsHeroImage({
    required this.heroTag,
    required this.thumbUrl,
    this.onPlay,
    super.key,
  });

  final String heroTag;
  final String thumbUrl;
  final VoidCallback? onPlay;

  /// 335 by 200 in the design.
  static const double aspectRatio = 335 / 200;

  @override
  Widget build(BuildContext context) {
    final onPlay = this.onPlay;

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: heroTag,
            child: ClipRRect(
              borderRadius: AppRadii.lgAll,
              child: AppNetworkImage(url: thumbUrl),
            ),
          ),
          if (onPlay != null)
            Center(
              child: Semantics(
                button: true,
                label: 'Play video',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onPlay,
                  child: SvgPicture.asset(AppAssets.playButton),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
