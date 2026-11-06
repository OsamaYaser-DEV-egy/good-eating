import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/app/app.dart';
import 'package:good_eating/core/widgets/screen_header.dart';
import 'package:good_eating/features/category_meals/presentation/pages/category_meals_page.dart';
import 'package:good_eating/features/home/presentation/widgets/home_section.dart';
import 'package:good_eating/features/meal_details/presentation/pages/meal_details_page.dart';
import 'package:good_eating/features/meals/presentation/widgets/category_chip.dart';
import 'package:good_eating/features/meals/presentation/widgets/meal_popular_card.dart';
import 'package:good_eating/features/meals/presentation/widgets/meal_recent_card.dart';
import 'package:good_eating/features/meals/presentation/widgets/meal_trending_card.dart';

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

/// The text [name] inside a card of type [card].
Finder inCard(Type card, String name) =>
    find.descendant(of: find.byType(card), matching: find.text(name));

Finder headerTitle(String name) =>
    find.descendant(of: find.byType(ScreenHeader), matching: find.text(name));

Finder chip(String name) =>
    find.ancestor(of: find.text(name), matching: find.byType(CategoryChip));

void main() {
  late FakeMealRepository repository;

  setUp(() async {
    repository = await setUpDependencies();
  });

  group('opening a meal from Home', () {
    testWidgets('a trending card opens that meal', (tester) async {
      await pumpApp(tester);

      await tester.tap(inCard(MealTrendingCard, 'Chicken dish 1'));
      await tester.pumpAndSettle();

      expect(find.byType(MealDetailsPage), findsOneWidget);
      expect(headerTitle('Chicken dish 1'), findsOneWidget);
      expect(repository.requestedDetails, ['Chicken-1']);
    });

    testWidgets('a recent card opens that meal', (tester) async {
      await pumpApp(tester);

      await tester.tap(inCard(MealRecentCard, 'Dessert dish 2'));
      await tester.pumpAndSettle();

      expect(headerTitle('Dessert dish 2'), findsOneWidget);
      expect(repository.requestedDetails, ['Dessert-2']);
    });

    testWidgets('a popular card opens that meal', (tester) async {
      await pumpApp(tester);

      // The third card is mostly off the right edge, so tap the second.
      await tester.tap(inCard(MealPopularCard, 'Beef dish 2'));
      await tester.pumpAndSettle();

      expect(headerTitle('Beef dish 2'), findsOneWidget);
      expect(repository.requestedDetails, ['Beef-2']);
    });

    testWidgets('shows the name straight away, before the recipe arrives', (
      tester,
    ) async {
      await pumpApp(tester);
      repository.holdDetails('Beef-1');

      await tester.tap(inCard(MealPopularCard, 'Beef dish 1'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(headerTitle('Beef dish 1'), findsOneWidget);
      expect(find.text('Ingredients'), findsNothing);
    });
  });

  group('the same meal shown twice on Home', () {
    testWidgets('opens from the popular carousel without a hero clash', (
      tester,
    ) async {
      await pumpApp(tester);
      // Trending already shows Chicken; make Popular show it too, so
      // Chicken dish 1 appears in both carousels at once.
      await tester.tap(chip('Chicken'));
      await tester.pumpAndSettle();
      expect(find.text('Chicken dish 1'), findsNWidgets(2));

      await tester.tap(inCard(MealPopularCard, 'Chicken dish 1'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(MealDetailsPage), findsOneWidget);
      expect(headerTitle('Chicken dish 1'), findsOneWidget);
    });

    testWidgets('opens from the trending carousel without a hero clash', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.tap(chip('Chicken'));
      await tester.pumpAndSettle();

      await tester.tap(inCard(MealTrendingCard, 'Chicken dish 1'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(MealDetailsPage), findsOneWidget);
    });
  });

  group('opening a meal from the category grid', () {
    Finder seeAllIn(String section) => find.descendant(
      of: find.ancestor(
        of: find.text(section),
        matching: find.byType(HomeSection),
      ),
      matching: find.bySemanticsLabel('See all'),
    );

    testWidgets('a grid card opens that meal, and back returns to the grid', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.tap(seeAllIn('Recent recipe'));
      await tester.pumpAndSettle();
      expect(find.byType(CategoryMealsPage), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(GridView),
          matching: find.text('Dessert dish 4'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MealDetailsPage), findsOneWidget);
      expect(repository.requestedDetails, ['Dessert-4']);

      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();

      expect(find.byType(MealDetailsPage), findsNothing);
      expect(find.byType(CategoryMealsPage), findsOneWidget);
    });
  });

  group('coming back', () {
    testWidgets('Back returns to Home as it was, without reloading it', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.tap(chip('Lamb'));
      await tester.pumpAndSettle();
      await tester.tap(inCard(MealPopularCard, 'Lamb dish 1'));
      await tester.pumpAndSettle();
      repository.requestedCategories.clear();
      final categoryCalls = repository.categoriesCalls;

      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();

      expect(find.byType(MealDetailsPage), findsNothing);
      expect(tester.getSemantics(chip('Lamb')), isSemantics(isSelected: true));
      expect(find.text('Lamb dish 1'), findsOneWidget);
      expect(repository.requestedCategories, isEmpty);
      expect(repository.categoriesCalls, categoryCalls);
    });

    testWidgets('the system back gesture also returns to Home', (tester) async {
      await pumpApp(tester);
      await tester.tap(inCard(MealTrendingCard, 'Chicken dish 1'));
      await tester.pumpAndSettle();

      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      await navigator.maybePop();
      await tester.pumpAndSettle();

      expect(find.byType(MealDetailsPage), findsNothing);
      expect(find.text('Find best recipes\nfor cooking'), findsOneWidget);
    });

    testWidgets('can open one meal after another', (tester) async {
      await pumpApp(tester);

      await tester.tap(inCard(MealPopularCard, 'Beef dish 1'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();
      await tester.tap(inCard(MealRecentCard, 'Dessert dish 1'));
      await tester.pumpAndSettle();

      expect(headerTitle('Dessert dish 1'), findsOneWidget);
      expect(repository.requestedDetails, ['Beef-1', 'Dessert-1']);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('opening a meal with the wrong arguments fails loudly', (
    tester,
  ) async {
    await pumpApp(tester);
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));

    expect(
      () => navigator.pushNamed('/meal-details', arguments: 'Beef-1'),
      throwsArgumentError,
    );
  });
}
