import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/core/error/failure.dart';
import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/core/widgets/app_empty_view.dart';
import 'package:good_eating/core/widgets/app_error_view.dart';
import 'package:good_eating/core/widgets/favorite_heart_button.dart';
import 'package:good_eating/features/favorites/presentation/widgets/favorites_list.dart';
import 'package:good_eating/features/meal_details/presentation/pages/meal_details_page.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';
import 'package:good_eating/features/meals/presentation/widgets/meal_card_list_skeleton.dart';
import 'package:good_eating/features/meals/presentation/widgets/meal_trending_card.dart';

import '../../../helpers/fake_favorites_repository.dart';
import '../../../helpers/pump_app.dart';
import '../../../helpers/test_dependencies.dart';

Finder savedHearts() => find.descendant(
  of: find.byType(FavoritesList),
  matching: find.byType(FavoriteHeartButton),
);

Finder savedCards() => find.descendant(
  of: find.byType(FavoritesList),
  matching: find.byType(MealTrendingCard),
);

List<String> savedNames(WidgetTester tester) => [
  for (final card in tester.widgetList<MealTrendingCard>(savedCards()))
    card.meal.name,
];

Future<void> openSavedTab(WidgetTester tester) async {
  await tester.tap(find.bySemanticsLabel('Saved'));
  await tester.pumpAndSettle();
}

void main() {
  final m1 = favoriteMeal(1);
  final m2 = favoriteMeal(2);
  final m3 = favoriteMeal(3);
  late FavoritesRepositoryFake favorites;

  /// Starts the app with [initial] already saved, on the Saved tab.
  Future<void> openWith(
    WidgetTester tester,
    List<MealSummary> initial, {
    double width = 375,
    double height = 2400,
  }) async {
    favorites = FavoritesRepositoryFake(initial: initial);
    await setUpDependencies(favorites: favorites);
    await pumpApp(tester, width: width, height: height);
    await openSavedTab(tester);
  }

  group('removing a meal', () {
    testWidgets('the heart removes it and offers Undo', (tester) async {
      await openWith(tester, [m1, m2, m3]);

      await tester.tap(savedHearts().at(1));
      await tester.pumpAndSettle();

      expect(savedNames(tester), ['Beef dish 1', 'Beef dish 3']);
      expect(find.text('Removed from favorites'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);
      expect(favorites.stored.map((m) => m.id), ['Beef-1', 'Beef-3']);
    });

    testWidgets('Undo puts it back in the same place', (tester) async {
      await openWith(tester, [m1, m2, m3]);
      await tester.tap(savedHearts().at(1));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(savedNames(tester), ['Beef dish 1', 'Beef dish 2', 'Beef dish 3']);
      expect(favorites.stored.map((m) => m.id), ['Beef-1', 'Beef-2', 'Beef-3']);
    });

    testWidgets('swiping a card away removes it and offers Undo', (
      tester,
    ) async {
      await openWith(tester, [m1, m2, m3]);

      await tester.drag(find.byType(Dismissible).at(0), const Offset(-600, 0));
      await tester.pumpAndSettle();

      expect(savedNames(tester), ['Beef dish 2', 'Beef dish 3']);
      expect(find.text('Removed from favorites'), findsOneWidget);
      expect(favorites.stored.map((m) => m.id), ['Beef-2', 'Beef-3']);
    });

    testWidgets('Undo after a swipe restores the card at its old position', (
      tester,
    ) async {
      await openWith(tester, [m1, m2, m3]);
      await tester.drag(find.byType(Dismissible).at(2), const Offset(-600, 0));
      await tester.pumpAndSettle();
      expect(savedNames(tester), ['Beef dish 1', 'Beef dish 2']);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(savedNames(tester), ['Beef dish 1', 'Beef dish 2', 'Beef dish 3']);
    });

    testWidgets('swiping the middle card and undoing restores the middle', (
      tester,
    ) async {
      await openWith(tester, [m1, m2, m3]);
      await tester.drag(find.byType(Dismissible).at(1), const Offset(-600, 0));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(savedNames(tester), ['Beef dish 1', 'Beef dish 2', 'Beef dish 3']);
    });

    testWidgets('swiping to the right does nothing', (tester) async {
      await openWith(tester, [m1, m2]);

      await tester.drag(find.byType(Dismissible).first, const Offset(600, 0));
      await tester.pumpAndSettle();

      expect(savedNames(tester), ['Beef dish 1', 'Beef dish 2']);
      expect(find.text('Removed from favorites'), findsNothing);
    });

    testWidgets('removing the last meal shows the empty state', (tester) async {
      await openWith(tester, [m1]);

      await tester.tap(savedHearts().first);
      await tester.pumpAndSettle();

      expect(find.byType(AppEmptyView), findsOneWidget);
      expect(find.text('No saved recipes yet'), findsOneWidget);
      expect(find.text('Removed from favorites'), findsOneWidget);
    });

    testWidgets('Undo after removing the last meal brings the list back', (
      tester,
    ) async {
      await openWith(tester, [m1]);
      await tester.tap(savedHearts().first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(savedNames(tester), ['Beef dish 1']);
      expect(find.text('No saved recipes yet'), findsNothing);
    });

    testWidgets('a second removal replaces the first snackbar', (tester) async {
      await openWith(tester, [m1, m2, m3]);

      await tester.tap(savedHearts().at(0));
      await tester.pumpAndSettle();
      await tester.tap(savedHearts().at(0));
      await tester.pumpAndSettle();

      expect(find.text('Removed from favorites'), findsOneWidget);
      expect(savedNames(tester), ['Beef dish 3']);
    });
  });

  group('states', () {
    testWidgets('shows a skeleton while the saved meals are read', (
      tester,
    ) async {
      favorites = FavoritesRepositoryFake(initial: [m1]);
      final hold = favorites.holdNextRead();
      await setUpDependencies(favorites: favorites);
      await pumpApp(tester, settle: false);

      await tester.tap(find.bySemanticsLabel('Saved'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(MealCardListSkeleton), findsOneWidget);
      expect(find.byType(AppEmptyView), findsNothing);

      hold.complete();
      await tester.pumpAndSettle();
      expect(savedNames(tester), ['Beef dish 1']);
    });

    testWidgets('shows the error with Try again when reading fails', (
      tester,
    ) async {
      favorites = FavoritesRepositoryFake()
        ..getResult = const Failed(CacheFailure());
      await setUpDependencies(favorites: favorites);
      await pumpApp(tester);
      await openSavedTab(tester);

      expect(find.byType(AppErrorView), findsOneWidget);
      expect(find.text(const CacheFailure().message), findsOneWidget);

      favorites
        ..getResult = null
        ..stored = [m1];
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(find.byType(AppErrorView), findsNothing);
      expect(savedNames(tester), ['Beef dish 1']);
    });

    testWidgets('shows the friendly empty state when nothing is saved', (
      tester,
    ) async {
      await openWith(tester, const []);

      expect(find.byType(AppEmptyView), findsOneWidget);
      expect(
        find.text('Tap the heart on any recipe to keep it here.'),
        findsOneWidget,
      );
    });

    testWidgets('a saved card opens its meal', (tester) async {
      await openWith(tester, [m1, m2]);

      await tester.tap(
        find.descendant(
          of: find.byType(FavoritesList),
          matching: find.text('Beef dish 2'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MealDetailsPage), findsOneWidget);
    });
  });

  group('layout', () {
    final many = [for (var i = 1; i <= 8; i++) favoriteMeal(i)];

    for (final width in [320.0, 375.0, 430.0]) {
      final label = width.toInt();

      testWidgets('has no overflow at $label wide, with saved meals', (
        tester,
      ) async {
        await openWith(tester, many, width: width);
        expect(tester.takeException(), isNull);
      });

      testWidgets('has no overflow at $label wide, scrolled to the end', (
        tester,
      ) async {
        await openWith(tester, many, width: width, height: 812);

        await tester.drag(find.byType(ListView).first, const Offset(0, -20000));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('has no overflow at $label wide, empty', (tester) async {
        await openWith(tester, const [], width: width);
        expect(tester.takeException(), isNull);
      });

      testWidgets('has no overflow at $label wide, on error', (tester) async {
        favorites = FavoritesRepositoryFake()
          ..getResult = const Failed(CacheFailure());
        await setUpDependencies(favorites: favorites);
        await pumpApp(tester, width: width);
        await openSavedTab(tester);

        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('lays each card out full width, 254 high, 16 apart', (
      tester,
    ) async {
      await openWith(tester, [m1, m2, m3]);

      final first = tester.getRect(savedCards().at(0));
      final second = tester.getRect(savedCards().at(1));

      expect(first.left, 20);
      expect(first.width, 335);
      expect(first.height, closeTo(254, 1));
      expect(second.top - first.bottom, closeTo(16, 1));
    });

    testWidgets('keeps the last card clear of the navigation bar', (
      tester,
    ) async {
      await openWith(tester, many, height: 812);

      await tester.drag(find.byType(ListView).first, const Offset(0, -20000));
      await tester.pumpAndSettle();

      final last = tester.getRect(savedCards().last);
      // The bar is 14 + 72 high.
      expect(last.bottom, lessThanOrEqualTo(812 - 86));
    });
  });
}
