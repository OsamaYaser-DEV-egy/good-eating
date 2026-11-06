import 'package:flutter/material.dart';

import 'package:good_eating/core/utils/ui_placeholders.dart';
import 'package:good_eating/core/widgets/entrance_animation.dart';
import 'package:good_eating/core/widgets/horizontal_list.dart';
import 'package:good_eating/features/home/presentation/widgets/creator_avatar_item.dart';
import 'package:good_eating/features/home/presentation/widgets/home_section.dart';

/// "Popular creators": a row of round portraits.
///
/// The creators are placeholders (see `UiPlaceholders`); TheMealDB has no
/// authors. Their list has no "See all" because there is nowhere to go.
class PopularCreatorsSection extends StatelessWidget {
  const PopularCreatorsSection({super.key});

  @override
  Widget build(BuildContext context) {
    const creators = UiPlaceholders.allCreators;

    return HomeSection(
      title: 'Popular creators',
      child: HorizontalList(
        height: CreatorAvatarItem.height,
        itemCount: creators.length,
        itemBuilder: (context, index) =>
            CreatorAvatarItem(creator: creators[index]).entrance(index: index),
      ),
    );
  }
}
