import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_eating/core/error/failure.dart';
import 'package:good_eating/core/widgets/favorite_heart_button.dart';
import 'package:good_eating/core/widgets/screen_header.dart';
import 'package:good_eating/features/favorites/data/datasources/favorites_local_data_source.dart';
import 'package:good_eating/features/favorites/presentation/widgets/favorites_list.dart';
import 'package:good_eating/features/meal_details/presentation/pages/meal_details_page.dart';
import 'package:good_eating/features/meals/presentation/widgets/category_chip.dart';
import 'package:good_eating/features/meals/presentation/widgets/meal_popular_card.dart';
import 'package:good_eating/features/meals/presentation/widgets/meal_trending_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/fake_favorites_repository.dart';
import '../../../helpers/pump_app.dart';
import '../../../helpers/test_dependencies.dart';

/// The heart inside the card of type [card] that shows [name].
Finder heartIn(Type card, String name) => find.descendant(
  of: find.ancestor(of: find.text(name), matching: find.byType(card)).first,
  matching: find.byType(FavoriteHeartButton),
);

bool isFilled(WidgetTester tester, Finder heart) =>
    tester.widget<FavoriteHeartButton>(heart).isFavorite;

/// The hearts on the Saved tab, top to bottom.
Finder savedHearts() => find.descendant(
  of: find.byType(FavoritesList),
  matching: find.byType(FavoriteHeartButton),
);

/// The names of the saved cards, top to bottom.
List<String> savedNames(WidgetTester tester) => [
  for (final card in tester.widgetList<MealTrendingCard>(
    find.descendant(
      of: find.byType(FavoritesList),
      matching: find.byType(MealTrendingCard),
    ),
  ))
    card.meal.name,
];

Future<void> openSavedTab(WidgetTester tester) async {
  await tester.tap(find.bySemanticsLabel('Saved'));
  await tester.pumpAndSettle();
}

Finder chip(String name) =>
    find.ancestor(of: find.text(name), matching: find.byType(CategoryChip));

void main() {
  setUp(() async {
    await setUpDependencies();
  });

  group('the heart', () {
    testWidgets('starts empty', (tester) async {
      await pumpApp(tester);

      expect(
        isFilled(tester, heartIn(MealTrendingCard, 'Chicken dish 1')),
        isFalse,
      );
      expect(
        isFilled(tester, heartIn(MealPopularCard, 'Beef dish 1')),
        isFalse,
      );
    });

    testWidgets('fills when tapped and saves the meal', (tester) async {
      await pumpApp(tester);

      await tester.tap(heartIn(MealTrendingCard, 'Chicken dish 1'));
      await tester.pumpAndSettle();

      expect(
        isFilled(tester, heartIn(MealTrendingCard, 'Chicken dish 1')),
        isTrue,
      );
      expect(await storedFavoriteIds(), ['Chicken-1']);
    });

    testWidgets('empties when tapped again and removes the meal', (
      tester,
    ) async {
      await pumpApp(tester);
      final heart = heartIn(MealPopularCard, 'Beef dish 1');

      await tester.tap(heart);
      await tester.pumpAndSettle();
      await tester.tap(heart);
      await tester.pumpAndSettle();

      expect(isFilled(tester, heart), isFalse);
      expect(await storedFavoriteIds(), isEmpty);
    });

    testWidgets('is filled everywhere the same meal appears', (tester) async {
      await pumpApp(tester);
      // Chicken is in Trending already; select it so Popular shows it too.
      await tester.tap(chip('Chicken'));
      await tester.pumpAndSettle();
      final trending = heartIn(MealTrendingCard, 'Chicken dish 1');
      final popular = heartIn(MealPopularCard, 'Chicken dish 1');

      await tester.tap(trending);
      await tester.pumpAndSettle();

      expect(isFilled(tester, trending), isTrue);
      expect(
        isFilled(tester, popular),
        isTrue,
        reason: 'the other card agrees',
      );

      await tester.tap(popular);
      await tester.pumpAndSettle();

      expect(isFilled(tester, trending), isFalse);
      expect(isFilled(tester, popular), isFalse);
    });

    testWidgets('only the tapped meal is filled', (tester) async {
      await pumpApp(tester);

      await tester.tap(heartIn(MealPopularCard, 'Beef dish 1'));
      await tester.pumpAndSettle();

      expect(
        isFilled(tester, heartIn(MealPopularCard, 'Beef dish 2')),
        isFalse,
      );
      expect(
        isFilled(tester, heartIn(MealTrendingCard, 'Chicken dish 1')),
        isFalse,
      );
    });

    testWidgets('tapping the heart does not open the meal', (tester) async {
      await pumpApp(tester);

      await tester.tap(heartIn(MealPopularCard, 'Beef dish 1'));
      await tester.pumpAndSettle();

      expect(find.byType(MealDetailsPage), findsNothing);
    });
  });

  group('the Saved tab', () {
    testWidgets('is empty to begin with, with a friendly message', (
      tester,
    ) async {
      await pumpApp(tester);
      await openSavedTab(tester);

      expect(find.text('Saved recipes'), findsOneWidget);
      expect(find.text('No saved recipes yet'), findsOneWidget);
      expect(find.byType(FavoritesList), findsNothing);
    });

    testWidgets('lists saved meals, newest first', (tester) async {
      await pumpApp(tester);

      await tester.tap(heartIn(MealPopularCard, 'Beef dish 1'));
      await tester.pumpAndSettle();
      await tester.tap(heartIn(MealTrendingCard, 'Chicken dish 1'));
      await tester.pumpAndSettle();
      await tester.tap(heartIn(MealPopularCard, 'Beef dish 2'));
      await tester.pumpAndSettle();
      await openSavedTab(tester);

      expect(savedNames(tester), [
        'Beef dish 2',
        'Chicken dish 1',
        'Beef dish 1',
      ]);
      expect(find.text('No saved recipes yet'), findsNothing);
    });

    testWidgets('a meal removed on Home leaves the list at once', (
      tester,
    ) async {
      await pumpApp(tester);
      final heart = heartIn(MealPopularCard, 'Beef dish 1');
      await tester.tap(heart);
      await tester.pumpAndSettle();
      await openSavedTab(tester);
      expect(savedNames(tester), ['Beef dish 1']);

      await tester.tap(find.bySemanticsLabel('Home'));
      await tester.pumpAndSettle();
      await tester.tap(heart);
      await tester.pumpAndSettle();
      await openSavedTab(tester);

      expect(find.text('No saved recipes yet'), findsOneWidget);
    });

    testWidgets('a saved card opens the meal, and back returns to the list', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.tap(heartIn(MealPopularCard, 'Beef dish 2'));
      await tester.pumpAndSettle();
      await openSavedTab(tester);

      await tester.tap(
        find.descendant(
          of: find.byType(FavoritesList),
          matching: find.text('Beef dish 2'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MealDetailsPage), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();

      expect(find.byType(MealDetailsPage), findsNothing);
      expect(savedNames(tester), ['Beef dish 2']);
    });
  });

  group('the heart on the details screen', () {
    testWidgets('reflects whether the meal is saved', (tester) async {
      await pumpApp(tester);
      await tester.tap(heartIn(MealPopularCard, 'Beef dish 1'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Beef dish 1'));
      await tester.pumpAndSettle();

      final heart = find.descendant(
        of: find.byType(ScreenHeader),
        matching: find.byType(FavoriteHeartButton),
      );
      expect(isFilled(tester, heart), isTrue);
    });

    testWidgets('saves the meal, and Home and Saved both show it', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.tap(find.text('Beef dish 2'));
      await tester.pumpAndSettle();
      final heart = find.descendant(
        of: find.byType(ScreenHeader),
        matching: find.byType(FavoriteHeartButton),
      );
      expect(isFilled(tester, heart), isFalse);

      await tester.tap(heart);
      await tester.pumpAndSettle();
      expect(isFilled(tester, heart), isTrue);
      expect(await storedFavoriteIds(), ['Beef-2']);

      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();
      expect(isFilled(tester, heartIn(MealPopularCard, 'Beef dish 2')), isTrue);

      await openSavedTab(tester);
      expect(savedNames(tester), ['Beef dish 2']);
    });

    testWidgets('removes the meal when tapped on a saved meal', (tester) async {
      await pumpApp(tester);
      await tester.tap(heartIn(MealPopularCard, 'Beef dish 1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Beef dish 1'));
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(ScreenHeader),
          matching: find.byType(FavoriteHeartButton),
        ),
      );
      await tester.pumpAndSettle();

      expect(await storedFavoriteIds(), isEmpty);
    });
  });

  group('closing and reopening the app', () {
    testWidgets('keeps the saved meals, in the same order', (tester) async {
      await pumpApp(tester);
      await tester.tap(heartIn(MealTrendingCard, 'Chicken dish 1'));
      await tester.pumpAndSettle();
      await tester.tap(heartIn(MealPopularCard, 'Beef dish 2'));
      await tester.pumpAndSettle();
      expect(await storedFavoriteIds(), ['Beef-2', 'Chicken-1']);

      // Close the app: drop the whole widget tree and dependency graph, but
      // leave what is on disk.
      await tester.pumpWidget(const SizedBox());
      await setUpDependencies(keepStorage: true);
      await pumpApp(tester);

      expect(
        isFilled(tester, heartIn(MealTrendingCard, 'Chicken dish 1')),
        isTrue,
      );
      expect(isFilled(tester, heartIn(MealPopularCard, 'Beef dish 2')), isTrue);
      expect(
        isFilled(tester, heartIn(MealPopularCard, 'Beef dish 1')),
        isFalse,
      );

      await openSavedTab(tester);
      expect(savedNames(tester), ['Beef dish 2', 'Chicken dish 1']);
    });

    testWidgets('a removal is kept too', (tester) async {
      await pumpApp(tester);
      await tester.tap(heartIn(MealPopularCard, 'Beef dish 1'));
      await tester.pumpAndSettle();
      await tester.tap(heartIn(MealPopularCard, 'Beef dish 1'));
      await tester.pumpAndSettle();

      await tester.pumpWidget(const SizedBox());
      await setUpDependencies(keepStorage: true);
      await pumpApp(tester);

      expect(
        isFilled(tester, heartIn(MealPopularCard, 'Beef dish 1')),
        isFalse,
      );
      await openSavedTab(tester);
      expect(find.text('No saved recipes yet'), findsOneWidget);
    });

    testWidgets('starts cleanly when the stored data is corrupt', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        FavoritesLocalDataSourceImpl.storageKey: '}{ not json at all',
      });
      await setUpDependencies(keepStorage: true);
      await pumpApp(tester);

      await openSavedTab(tester);
      expect(find.text('No saved recipes yet'), findsOneWidget);

      // And saving works, replacing the corrupt value.
      await tester.tap(find.bySemanticsLabel('Home'));
      await tester.pumpAndSettle();
      await tester.tap(heartIn(MealPopularCard, 'Beef dish 1'));
      await tester.pumpAndSettle();

      expect(await storedFavoriteIds(), ['Beef-1']);
    });
  });

  group('when saving fails', () {
    testWidgets('tells the user and puts the heart back', (tester) async {
      final favorites = FavoritesRepositoryFake()..failingSaves = 1;
      await setUpDependencies(favorites: favorites);
      await pumpApp(tester);

      await tester.tap(heartIn(MealPopularCard, 'Beef dish 1'));
      await tester.pumpAndSettle();

      expect(find.text(const CacheFailure().message), findsOneWidget);
      expect(
        isFilled(tester, heartIn(MealPopularCard, 'Beef dish 1')),
        isFalse,
      );
      expect(favorites.stored, isEmpty);
    });

    testWidgets('shows the message on whichever screen is open', (
      tester,
    ) async {
      final favorites = FavoritesRepositoryFake()..failingSaves = 1;
      await setUpDependencies(favorites: favorites);
      await pumpApp(tester);
      await tester.tap(find.text('Beef dish 1'));
      await tester.pumpAndSettle();
      expect(find.byType(MealDetailsPage), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(ScreenHeader),
          matching: find.byType(FavoriteHeartButton),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(const CacheFailure().message), findsOneWidget);
    });

    testWidgets('the next tap works normally', (tester) async {
      final favorites = FavoritesRepositoryFake()..failingSaves = 1;
      await setUpDependencies(favorites: favorites);
      await pumpApp(tester);
      final heart = heartIn(MealPopularCard, 'Beef dish 1');

      await tester.tap(heart);
      await tester.pumpAndSettle();
      await tester.tap(heart);
      await tester.pumpAndSettle();

      expect(isFilled(tester, heart), isTrue);
      expect(favorites.stored.map((m) => m.id), ['Beef-1']);
    });
  });
}
