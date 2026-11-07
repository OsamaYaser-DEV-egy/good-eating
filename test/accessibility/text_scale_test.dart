import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/core/error/failure.dart';
import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/features/meals/presentation/widgets/meal_popular_card.dart';

import '../helpers/fake_favorites_repository.dart';
import '../helpers/fake_meal_repository.dart';
import '../helpers/pump_app.dart';
import '../helpers/test_dependencies.dart';

/// Opens every screen with the system text size turned up and checks that
/// nothing overflows. Many people run their phone at 130 % or more.
void main() {
  for (final scale in const [1.3, 2.0]) {
    group('at ${scale}x text size', () {
      late FakeMealRepository repository;

      setUp(() async {
        repository = await setUpDependencies(
          favorites: FavoritesRepositoryFake(
            initial: [for (var i = 1; i <= 3; i++) favoriteMeal(i)],
          ),
        );
      });

      Future<void> open(WidgetTester tester, {bool settle = true}) async {
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await pumpApp(tester, settle: settle);
      }

      Future<void> goTo(WidgetTester tester, String tab) async {
        await tester.tap(find.bySemanticsLabel(tab));
        await tester.pumpAndSettle();
      }

      testWidgets('Home', (tester) async {
        await open(tester);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Home, loading', (tester) async {
        repository.holdCategories();
        await open(tester, settle: false);
        await tester.pump(const Duration(seconds: 1));
        expect(tester.takeException(), isNull);
      });

      testWidgets('Home, failed', (tester) async {
        repository.categoriesResult = const Failed(NetworkFailure());
        await open(tester);
        expect(tester.takeException(), isNull);
      });

      testWidgets('the category grid', (tester) async {
        await open(tester);
        await tester.tap(find.bySemanticsLabel('See all').first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('the meal details', (tester) async {
        await open(tester);
        await tester.tap(
          find.descendant(
            of: find.byType(MealPopularCard).first,
            matching: find.text('Beef dish 1'),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('Saved', (tester) async {
        await open(tester);
        await goTo(tester, 'Saved');
        expect(tester.takeException(), isNull);
      });

      testWidgets('Search, with results', (tester) async {
        await open(tester);
        await goTo(tester, 'Search');
        await tester.enterText(find.byType(TextField), 'soup');
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('Search, nothing found', (tester) async {
        await open(tester);
        await goTo(tester, 'Search');
        await tester.enterText(find.byType(TextField), 'zzzz');
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('Notifications', (tester) async {
        await open(tester);
        await goTo(tester, 'Notifications');
        expect(tester.takeException(), isNull);
      });

      testWidgets('Profile', (tester) async {
        await open(tester);
        await goTo(tester, 'Profile');
        expect(tester.takeException(), isNull);
      });

      testWidgets('the welcome screen on a small phone', (tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await pumpApp(tester, width: 320, height: 568, showOnboarding: true);
        expect(tester.takeException(), isNull);
      });
    });
  }
}
