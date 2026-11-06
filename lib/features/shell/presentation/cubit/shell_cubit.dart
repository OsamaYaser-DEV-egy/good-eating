import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:good_eating/features/shell/presentation/cubit/shell_tab.dart';

/// Tracks which tab of the app shell is showing.
class ShellCubit extends Cubit<ShellTab> {
  ShellCubit() : super(ShellTab.home);

  void select(ShellTab tab) => emit(tab);
}
