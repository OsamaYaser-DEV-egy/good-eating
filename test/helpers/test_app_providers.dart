import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:good_eating/app/di/injector.dart';
import 'package:good_eating/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:good_eating/features/meals/presentation/cubit/categories_cubit.dart';
import 'package:good_eating/features/shell/presentation/cubit/shell_cubit.dart';

/// The cubits `App` provides above the navigator, for tests that build a
/// single screen instead of the whole app.
///
/// Pass [shell] for screens that switch tabs.
class TestAppProviders extends StatelessWidget {
  const TestAppProviders({required this.child, this.shell, super.key});

  final Widget child;
  final ShellCubit? shell;

  @override
  Widget build(BuildContext context) {
    final shell = this.shell;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<CategoriesCubit>()..load()),
        BlocProvider(create: (_) => getIt<FavoritesCubit>()..load()),
        if (shell != null) BlocProvider.value(value: shell),
      ],
      child: child,
    );
  }
}
