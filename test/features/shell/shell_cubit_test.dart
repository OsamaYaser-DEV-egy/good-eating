import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/features/shell/presentation/cubit/shell_cubit.dart';
import 'package:good_eating/features/shell/presentation/cubit/shell_tab.dart';

void main() {
  blocTest<ShellCubit, ShellTab>(
    'starts on the home tab',
    build: ShellCubit.new,
    verify: (cubit) => expect(cubit.state, ShellTab.home),
  );

  blocTest<ShellCubit, ShellTab>(
    'emits the selected tab',
    build: ShellCubit.new,
    act: (cubit) => cubit
      ..select(ShellTab.saved)
      ..select(ShellTab.search),
    expect: () => [ShellTab.saved, ShellTab.search],
  );

  blocTest<ShellCubit, ShellTab>(
    'does not re-emit when the same tab is selected twice in a row',
    build: ShellCubit.new,
    act: (cubit) => cubit
      ..select(ShellTab.saved)
      ..select(ShellTab.saved),
    expect: () => [ShellTab.saved],
  );
}
