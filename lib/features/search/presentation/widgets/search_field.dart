import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:good_eating/core/constants/app_assets.dart';
import 'package:good_eating/core/theme/app_colors.dart';
import 'package:good_eating/core/theme/app_radii.dart';
import 'package:good_eating/core/theme/app_spacing.dart';
import 'package:good_eating/core/theme/app_text_styles.dart';

/// The search box from the design (`139:3178`) as a real text field: a 44 px
/// white box with a 1 px border, a search icon and a hint, plus a clear button
/// while there is text.
class SearchField extends StatelessWidget {
  const SearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  static const String hint = 'Search recipes';
  static const double height = 44;
  static const double _iconBox = 20;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.sm,
      ),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) => TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          textInputAction: TextInputAction.search,
          textCapitalization: TextCapitalization.sentences,
          autocorrect: false,
          cursorColor: AppColors.primary50,
          style: AppTextStyles.labelRegular,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.labelRegular.copyWith(
              color: AppColors.neutral30,
            ),
            filled: true,
            fillColor: AppColors.white,
            isDense: true,
            constraints: const BoxConstraints.tightFor(height: height),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.md,
              ),
              child: SizedBox.square(
                dimension: _iconBox,
                child: Center(child: SvgPicture.asset(AppAssets.search)),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear',
                    onPressed: onClear,
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: AppColors.neutral50,
                    ),
                  ),
            enabledBorder: _border(AppColors.neutral20),
            focusedBorder: _border(AppColors.primary50),
            border: _border(AppColors.neutral20),
          ),
        ),
      ),
    );
  }

  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: AppRadii.controlAll,
    borderSide: BorderSide(color: color),
  );
}
