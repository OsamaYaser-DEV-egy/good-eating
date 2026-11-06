import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/app/app.dart';
import 'package:good_eating/core/error/failure.dart';
import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/core/widgets/screen_header.dart';
import 'package:good_eating/features/category_meals/presentation/pages/category_meals_page.dart';
import 'package:good_eating/features/home/presentation/widgets/home_section.dart';
import 'package:good_eating/features/meals/presentation/widgets/category_chip.dart';

import '../../helpers/fake_meal_repository.dart';
import '../../helpers/test_dependencies.dart';

/// Home is built lazily, so the screen is tall enough to build every section.
Future<void> pumpApp(WidgetTester tester) async {
  tester.view
    ..physicalSize = const Size(375, 2400)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const App());
  await tester.pumpAndSettle();
}

/// The "See all" button inside the Home section titled [sectionTitle].
Finder seeAllIn(String sectionTitle) => find.descendant(
  of: find.ancestor(
    of: find.text(sectionTitle),
    matching: find.byType(HomeSection),
  ),
  matching: find.bySemanticsLabel('See all'),
);

Finder chip(String name) =>
    find.ancestor(of: find.text(name), matching: find.byType(CategoryChip));

Finder gridTitle(String name) =>
    find.descendant(of: find.byType(ScreenHeader), matching: find.text(name));

void main() {
  late FakeMealRepository repository;

  setUp(() async {
    repository = await setUpDependencies();
  });

  group('Trending now', () {
    testWidgets('See all opens the grid for the trending category', (
      tester,
    ) async {
      await pumpApp(tester);

      await tester.tap(seeAllIn('Trending now 🔥'));
      await tester.pumpAndSettle();

      expect(find.byType(CategoryMealsPage), findsOneWidget);
      expect(gridTitle('Chicken'), findsOneWidget);
      expect(
        tester.getSemantics(chip('Chicken').last),
        isSemantics(isSelected: true),
      );
    });
  });

  group('Recent recipe', () {
    testWidgets('See all opens the grid for the recent category', (
      tester,
    ) async {
      await pumpApp(tester);

      await tester.tap(seeAllIn('Recent recipe'));
      await tester.pumpAndSettle();

      expect(find.byType(CategoryMealsPage), findsOneWidget);
      expect(gridTitle('Dessert'), findsOneWidget);
    });
  });

  group('Popular category', () {
    testWidgets('See all opens the grid for the first category by default', (
      tester,
    ) async {
      await pumpApp(tester);

      await tester.tap(seeAllIn('Popular category'));
      await tester.pumpAndSettle();

      expect(gridTitle('Beef'), findsOneWidget);
    });

    testWidgets('See all opens whichever chip is selected on Home', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.tap(chip('Lamb'));
      await tester.pumpAndSettle();

      await tester.tap(seeAllIn('Popular category'));
      await tester.pumpAndSettle();

      expect(gridTitle('Lamb'), findsOneWidget);
      expect(find.text('Lamb dish 1'), findsWidgets);
    });
  });

  group('the two screens are independent', () {
    testWidgets('choosing a chip on the grid does not change Home', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.tap(chip('Lamb'));
      await tester.pumpAndSettle();
      await tester.tap(seeAllIn('Popular category'));
      await tester.pumpAndSettle();

      // On the grid, pick a different category.
      await tester.tap(chip('Dessert').last);
      await tester.pumpAndSettle();
      expect(gridTitle('Dessert'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();

      expect(find.byType(CategoryMealsPage), findsNothing);
      // Home still has Lamb selected and still shows Lamb's meals.
      expect(tester.getSemantics(chip('Lamb')), isSemantics(isSelected: true));
      expect(find.text('Lamb dish 1'), findsOneWidget);
    });

    testWidgets('going back does not reload Home', (tester) async {
      await pumpApp(tester);
      await tester.tap(seeAllIn('Trending now 🔥'));
      await tester.pumpAndSettle();
      repository.requestedCategories.clear();
      final categoryCalls = repository.categoriesCalls;

      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();

      expect(repository.requestedCategories, isEmpty);
      expect(repository.categoriesCalls, categoryCalls);
    });

    testWidgets('the system back gesture also returns to Home', (tester) async {
      await pumpApp(tester);
      await tester.tap(seeAllIn('Trending now 🔥'));
      await tester.pumpAndSettle();

      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      await navigator.maybePop();
      await tester.pumpAndSettle();

      expect(find.byType(CategoryMealsPage), findsNothing);
      expect(find.text('Find best recipes\nfor cooking'), findsOneWidget);
    });
  });

  group('See all visibility', () {
    testWidgets('is hidden while the categories are loading', (tester) async {
      tester.view
        ..physicalSize = const Size(375, 2400)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      repository.holdCategories();

      await tester.pumpWidget(const App());
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.bySemanticsLabel('See all'), findsNothing);
      // The creators row is static and animates in on a delay.
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('is hidden on a carousel that failed to load', (tester) async {
      repository.mealsOverrides['Chicken'] = const Failed(TimeoutFailure());
      await pumpApp(tester);

      expect(seeAllIn('Trending now 🔥'), findsNothing);
      expect(seeAllIn('Recent recipe'), findsNothing);
      // Popular category loaded fine and still offers it.
      expect(seeAllIn('Popular category'), findsOneWidget);
    });

    testWidgets('is never offered on the creators row', (tester) async {
      await pumpApp(tester);
      expect(seeAllIn('Popular creators'), findsNothing);
    });
  });

  testWidgets('opening the grid with the wrong arguments fails loudly', (
    tester,
  ) async {
    await pumpApp(tester);
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));

    expect(
      () => navigator.pushNamed('/category-meals', arguments: 'Beef'),
      throwsArgumentError,
    );
  });
}
