import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/core/error/failure.dart';
import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/core/utils/ui_placeholders.dart';
import 'package:good_eating/core/widgets/app_empty_view.dart';
import 'package:good_eating/core/widgets/app_error_view.dart';
import 'package:good_eating/core/widgets/favorite_heart_button.dart';
import 'package:good_eating/features/meal_details/presentation/pages/meal_details_page.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';
import 'package:good_eating/features/meals/presentation/widgets/meal_popular_card.dart';
import 'package:good_eating/features/profile/presentation/widgets/profile_recipe_card.dart';

import '../../helpers/fake_favorites_repository.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_dependencies.dart';

final _m1 = favoriteMeal(1);
final _m2 = favoriteMeal(2);
final _m3 = favoriteMeal(3);

Future<void> _openProfile(WidgetTester tester) async {
  await tester.tap(find.bySemanticsLabel('Profile'));
  await tester.pumpAndSettle();
}

/// Opens the app with [saved] already saved, on the Profile tab.
Future<FavoritesRepositoryFake> _openWith(
  WidgetTester tester,
  List<MealSummary> saved, {
  double width = 375,
  double height = 2400,
}) async {
  final favorites = FavoritesRepositoryFake(initial: saved);
  await setUpDependencies(favorites: favorites);
  await pumpApp(tester, width: width, height: height);
  await _openProfile(tester);
  return favorites;
}

List<String> _cardNames(WidgetTester tester) => [
  for (final card in tester.widgetList<ProfileRecipeCard>(
    find.byType(ProfileRecipeCard),
  ))
    card.meal.name,
];

void main() {
  setUp(() async {
    await setUpDependencies();
  });

  group('the person', () {
    testWidgets('shows the name, bio and portrait from the design', (
      tester,
    ) async {
      await _openWith(tester, const []);

      expect(find.text('My profile'), findsOneWidget);
      expect(find.text(UiPlaceholders.profile.name), findsOneWidget);
      expect(find.text(UiPlaceholders.profile.bio), findsOneWidget);
      expect(find.bySemanticsLabel('Profile photo'), findsOneWidget);
    });

    testWidgets('draws the portrait as a 100 px circle', (tester) async {
      await _openWith(tester, const []);

      final size = tester.getSize(find.bySemanticsLabel('Profile photo'));
      expect(size, const Size(100, 100));
      expect(find.byType(ClipOval), findsWidgets);
    });

    testWidgets('has an Edit profile button that does nothing', (tester) async {
      await _openWith(tester, [_m1]);

      await tester.tap(find.bySemanticsLabel('Edit profile'));
      await tester.pumpAndSettle();

      expect(find.text('My profile'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('the counts', () {
    testWidgets('label all four', (tester) async {
      await _openWith(tester, const []);

      for (final label in ['Recipe', 'Videos', 'Followers', 'Following']) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('show the design’s example numbers for the others', (
      tester,
    ) async {
      await _openWith(tester, const []);

      expect(find.bySemanticsLabel('Videos 13'), findsOneWidget);
      expect(find.bySemanticsLabel('Followers 14K'), findsOneWidget);
      expect(find.bySemanticsLabel('Following 120'), findsOneWidget);
    });

    testWidgets('Recipe is the real number of saved meals', (tester) async {
      await _openWith(tester, [_m1, _m2, _m3]);
      expect(find.bySemanticsLabel('Recipe 3'), findsOneWidget);
    });

    testWidgets('Recipe is zero when nothing is saved', (tester) async {
      await _openWith(tester, const []);
      expect(find.bySemanticsLabel('Recipe 0'), findsOneWidget);
    });

    testWidgets('are spread across the full width, edge to edge', (
      tester,
    ) async {
      await _openWith(tester, const []);

      final first = tester.getRect(find.text('Recipe'));
      final last = tester.getRect(find.text('Following'));

      expect(first.left, closeTo(20, 1.5));
      expect(last.right, closeTo(375 - 20, 1.5));
    });

    testWidgets('follow the saved meals as they change', (tester) async {
      await _openWith(tester, [_m1, _m2]);
      expect(find.bySemanticsLabel('Recipe 2'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(ProfileRecipeCard).first,
          matching: find.byType(FavoriteHeartButton),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Recipe 1'), findsOneWidget);
    });
  });

  group('the recipes', () {
    testWidgets('are the saved meals, newest first', (tester) async {
      await _openWith(tester, [_m3, _m1, _m2]);

      expect(_cardNames(tester), ['Beef dish 3', 'Beef dish 1', 'Beef dish 2']);
    });

    testWidgets('show a rating, ingredient count and time on each card', (
      tester,
    ) async {
      await _openWith(tester, [_m1, _m2, _m3]);

      expect(
        find.textContaining(RegExp(r'^\d+ Ingredients$')),
        findsNWidgets(3),
      );
      expect(find.textContaining(RegExp(r'^\d+ min$')), findsNWidgets(3));
      expect(find.textContaining(RegExp(r'^\d,\d$')), findsNWidgets(3));
    });

    testWidgets('show hearts that are filled, because they are saved', (
      tester,
    ) async {
      await _openWith(tester, [_m1]);

      final heart = tester.widget<FavoriteHeartButton>(
        find.descendant(
          of: find.byType(ProfileRecipeCard),
          matching: find.byType(FavoriteHeartButton),
        ),
      );
      expect(heart.isFavorite, isTrue);
    });

    testWidgets('removing one with its heart takes it off the list', (
      tester,
    ) async {
      final favorites = await _openWith(tester, [_m1, _m2]);

      await tester.tap(
        find.descendant(
          of: find.byType(ProfileRecipeCard).first,
          matching: find.byType(FavoriteHeartButton),
        ),
      );
      await tester.pumpAndSettle();

      expect(_cardNames(tester), ['Beef dish 2']);
      expect(favorites.stored.map((m) => m.id), ['Beef-2']);
    });

    testWidgets('a card opens its meal, and back returns', (tester) async {
      await _openWith(tester, [_m1, _m2]);

      await tester.tap(find.text('Beef dish 2'));
      await tester.pumpAndSettle();
      expect(find.byType(MealDetailsPage), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();

      expect(find.byType(MealDetailsPage), findsNothing);
      expect(_cardNames(tester), ['Beef dish 1', 'Beef dish 2']);
    });

    testWidgets('a meal saved on Home appears here', (tester) async {
      await setUpDependencies();
      await pumpApp(tester);
      await tester.tap(
        find.descendant(
          of: find.ancestor(
            of: find.text('Beef dish 1'),
            matching: find.byType(MealPopularCard),
          ),
          matching: find.byType(FavoriteHeartButton),
        ),
      );
      await tester.pumpAndSettle();

      await _openProfile(tester);

      expect(_cardNames(tester), ['Beef dish 1']);
      expect(find.bySemanticsLabel('Recipe 1'), findsOneWidget);
    });
  });

  group('states', () {
    testWidgets('shows a friendly message when nothing is saved', (
      tester,
    ) async {
      await _openWith(tester, const []);

      expect(find.byType(AppEmptyView), findsOneWidget);
      expect(find.text('No recipes yet'), findsOneWidget);
      expect(find.byType(ProfileRecipeCard), findsNothing);
    });

    testWidgets('shows a skeleton and a dash while the saved meals load', (
      tester,
    ) async {
      final favorites = FavoritesRepositoryFake(initial: [_m1]);
      final hold = favorites.holdNextRead();
      await setUpDependencies(favorites: favorites);
      await pumpApp(tester, settle: false);

      await tester.tap(find.bySemanticsLabel('Profile'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ProfileRecipeCardSkeleton), findsOneWidget);
      expect(find.bySemanticsLabel('Recipe –'), findsOneWidget);

      hold.complete();
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Recipe 1'), findsOneWidget);
    });

    testWidgets('shows the error with Try again when reading fails', (
      tester,
    ) async {
      final favorites = FavoritesRepositoryFake()
        ..getResult = const Failed(CacheFailure());
      await setUpDependencies(favorites: favorites);
      await pumpApp(tester);
      await _openProfile(tester);

      expect(find.byType(AppInlineError), findsOneWidget);
      expect(find.text(const CacheFailure().message), findsOneWidget);
      // The person is still shown.
      expect(find.text(UiPlaceholders.profile.name), findsOneWidget);

      favorites
        ..getResult = null
        ..stored = [_m1];
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(_cardNames(tester), ['Beef dish 1']);
    });
  });

  group('layout', () {
    final many = [for (var i = 1; i <= 6; i++) favoriteMeal(i)];

    for (final width in [320.0, 375.0, 430.0]) {
      final label = width.toInt();

      testWidgets('has no overflow at $label wide, with recipes', (
        tester,
      ) async {
        await _openWith(tester, many, width: width);
        expect(tester.takeException(), isNull);
      });

      testWidgets('has no overflow at $label wide, scrolled to the end', (
        tester,
      ) async {
        await _openWith(tester, many, width: width, height: 812);

        await tester.drag(
          find.byType(CustomScrollView).last,
          const Offset(0, -20000),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('has no overflow at $label wide, empty', (tester) async {
        await _openWith(tester, const [], width: width);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('draws each card 335 by 200, 16 apart', (tester) async {
      await _openWith(tester, [_m1, _m2]);

      final first = tester.getRect(find.byType(ProfileRecipeCard).at(0));
      final second = tester.getRect(find.byType(ProfileRecipeCard).at(1));

      expect(first.left, 20);
      expect(first.width, 335);
      expect(first.height, 200);
      expect(second.top - first.bottom, 16);
    });

    testWidgets('keeps the last card clear of the navigation bar', (
      tester,
    ) async {
      await _openWith(tester, many, height: 812);

      await tester.drag(
        find.byType(CustomScrollView).last,
        const Offset(0, -20000),
      );
      await tester.pumpAndSettle();

      final last = tester.getRect(find.byType(ProfileRecipeCard).last);
      expect(last.bottom, lessThanOrEqualTo(812 - 86));
    });
  });
}
