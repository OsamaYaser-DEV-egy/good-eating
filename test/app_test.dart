import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/app/app.dart';
import 'package:good_eating/features/search/presentation/widgets/search_field.dart';

import 'helpers/fake_meal_repository.dart';
import 'helpers/test_dependencies.dart';

void main() {
  late FakeMealRepository repository;

  setUp(() async {
    repository = await setUpDependencies();
  });

  testWidgets('boots into the shell on the Home tab, with Home loaded', (
    tester,
  ) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.text('Find best recipes\nfor cooking'), findsOneWidget);
    expect(find.text('Popular category'), findsOneWidget);
    expect(find.text('Beef dish 1'), findsOneWidget);
  });

  testWidgets('loads the categories once for the whole app', (tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    // App-level cubit, Home's meals cubit and Home's feed cubit each ask the
    // repository, which serves them all from one cache in the real app.
    expect(repository.categoriesCalls, 3);
  });

  testWidgets('switching tabs shows the matching body', (tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('My profile'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Notifications'));
    await tester.pumpAndSettle();
    expect(find.text('Today'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Saved'));
    await tester.pumpAndSettle();
    expect(find.text('Saved recipes'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Search'));
    await tester.pumpAndSettle();
    expect(find.byType(SearchField), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Popular category'), findsOneWidget);
  });

  testWidgets('Home keeps its state while another tab is showing', (
    tester,
  ) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    repository.requestedCategories.clear();

    await tester.tap(find.bySemanticsLabel('Saved'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Home'));
    await tester.pumpAndSettle();

    expect(repository.requestedCategories, isEmpty);
    expect(find.text('Beef dish 1'), findsOneWidget);
  });
}
