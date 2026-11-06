import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:good_eating/core/constants/app_durations.dart';
import 'package:good_eating/core/widgets/app_empty_view.dart';
import 'package:good_eating/core/widgets/app_error_view.dart';
import 'package:good_eating/core/widgets/page_heading.dart';
import 'package:good_eating/features/meals/presentation/widgets/meal_card_list_skeleton.dart';
import 'package:good_eating/features/search/presentation/cubit/search_cubit.dart';
import 'package:good_eating/features/search/presentation/cubit/search_state.dart';
import 'package:good_eating/features/search/presentation/widgets/search_field.dart';
import 'package:good_eating/features/search/presentation/widgets/search_results_list.dart';
import 'package:good_eating/features/shell/presentation/cubit/shell_cubit.dart';
import 'package:good_eating/features/shell/presentation/cubit/shell_tab.dart';

/// The Search tab: a heading, the search field, and below it whatever the
/// search has produced.
///
/// The field takes focus when the tab is opened and gives it up when the user
/// leaves, so the keyboard appears when it is wanted and never at launch,
/// while this tab is still hidden behind Home.
class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTabChanged(BuildContext context, ShellTab tab) {
    if (tab != ShellTab.search) {
      _focusNode.unfocus();
      return;
    }

    // While another tab is showing, this one is hidden and its field cannot
    // take focus. It only can once the frame that reveals the tab is built, so
    // ask then, and only if the user is still on the Search tab.
    final shell = context.read<ShellCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && shell.state == ShellTab.search) _focusNode.requestFocus();
    });
  }

  void _clear() {
    _controller.clear();
    context.read<SearchCubit>().onQueryChanged('');
    // The clear button takes focus with the tap; hand it back to the field.
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SearchCubit>();

    return BlocListener<ShellCubit, ShellTab>(
      listener: _onTabChanged,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const PageHeading(title: 'Search recipes'),
            SearchField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: cubit.onQueryChanged,
              onSubmitted: cubit.submit,
              onClear: _clear,
            ),
            const Expanded(child: _SearchBody()),
          ],
        ),
      ),
    );
  }
}

class _SearchBody extends StatelessWidget {
  const _SearchBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) => AnimatedSwitcher(
        duration: AppDurations.fast,
        child: KeyedSubtree(
          // Results for a new query replace the old ones in place; only a
          // change of kind (loading, results, empty, error) cross-fades.
          key: ValueKey(state.runtimeType),
          child: switch (state) {
            SearchIdle() => const AppEmptyView(
              icon: Icons.search_rounded,
              title: 'Search for a recipe',
              message: 'Type the name of a dish, for example "Arrabiata".',
            ),
            SearchLoading() => const MealCardListSkeleton(),
            SearchResults(:final meals) => SearchResultsList(meals: meals),
            SearchEmpty(:final query) => AppEmptyView(
              icon: Icons.search_off_rounded,
              title: 'No recipes found',
              message: 'We could not find "$query". Try another name.',
            ),
            SearchError(:final failure) => AppErrorView(
              failure: failure,
              onRetry: context.read<SearchCubit>().retry,
            ),
          },
        ),
      ),
    );
  }
}
