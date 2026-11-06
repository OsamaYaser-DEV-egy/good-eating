import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:good_eating/app/di/injector.dart';
import 'package:good_eating/features/search/presentation/cubit/search_cubit.dart';
import 'package:good_eating/features/search/presentation/widgets/search_view.dart';

/// The Search tab. It owns its cubit, and the shell keeps the tab alive, so
/// the text and results are still there after visiting another tab.
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SearchCubit>(),
      child: const SearchView(),
    );
  }
}
