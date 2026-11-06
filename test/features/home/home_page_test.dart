import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_eating/core/error/failure.dart';
import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/core/widgets/app_error_view.dart';
import 'package:good_eating/features/home/presentation/widgets/creator_avatar_item.dart';
import 'package:good_eating/features/meals/presentation/widgets/category_chip.dart';
import 'package:good_eating/features/meals/presentation/widgets/meal_popular_card.dart';
import 'package:good_eating/features/meals/presentation/widgets/meal_recent_card.dart';
import 'package:good_eating/features/meals/presentation/widgets/meal_trending_card.dart';
import 'package:good_eating/features/shell/presentation/cubit/shell_tab.dart';

import '../../helpers/fake_meal_repository.dart';
import '../../helpers/pump_home.dart';
import '../../helpers/test_dependencies.dart';

void main() {
  late FakeMealRepository repository;

  setUp(() async {
    repository = await setUpDependencies();
  });

  /// Finds a chip by its category name.
  Finder chip(String name) =>
      find.ancestor(of: find.text(name), matching: find.byType(CategoryChip));

  group('while loading', () {
    testWidgets('shows the heading and search field with skeletons below', (
      tester,
    ) async {
      repository.holdCategories();
      await pumpHome(tester);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Find best recipes\nfor cooking'), findsOneWidget);
      expect(find.text('Search recipes'), findsOneWidget);
      expect(find.byType(MealTrendingCardSkeleton), findsWidgets);
      expect(find.byType(MealPopularCardSkeleton), findsWidgets);
      expect(find.byType(MealRecentCardSkeleton), findsWidgets);
      expect(find.byType(CategoryChip), findsNothing);
      expect(find.byType(AppErrorView), findsNothing);

      // The static creators row animates in on a delay; let those timers
      // finish. The skeletons' shimmer loops forever, so settling is not an
      // option here.
      await tester.pump(const Duration(seconds: 1));
    });
  });

  group('once loaded', () {
    testWidgets('shows every section with its meals', (tester) async {
      await pumpHome(tester);
      await tester.pumpAndSettle();

      expect(find.text('Trending now 🔥'), findsOneWidget);
      expect(find.text('Popular category'), findsOneWidget);
      expect(find.text('Recent recipe'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Popular creators'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Popular creators'), findsOneWidget);
      expect(find.byType(CreatorAvatarItem), findsNWidgets(4));
    });

    testWidgets('lists every category as a chip, the first one selected', (
      tester,
    ) async {
      await pumpHome(tester);
      await tester.pumpAndSettle();

      expect(
        find.byType(CategoryChip),
        findsNWidgets(fakeCategoryNames.length),
      );
      for (final name in fakeCategoryNames) {
        expect(find.text(name), findsWidgets);
      }
      expect(tester.getSemantics(chip('Beef')), isSemantics(isSelected: true));
      expect(
        tester.getSemantics(chip('Chicken')),
        isNot(isSemantics(isSelected: true)),
      );
    });

    testWidgets('opens the popular carousel on the first category', (
      tester,
    ) async {
      await pumpHome(tester);
      await tester.pumpAndSettle();

      expect(find.byType(MealPopularCard), findsWidgets);
      expect(find.text('Beef dish 1'), findsOneWidget);
    });

    testWidgets('previews the second category as trending and the third as '
        'recent, never the first', (tester) async {
      await pumpHome(tester);
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(MealTrendingCard),
          matching: find.text('Chicken dish 1'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(MealRecentCard),
          matching: find.text('Dessert dish 1'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(MealTrendingCard),
          matching: find.textContaining('Beef'),
        ),
        findsNothing,
      );
    });

    testWidgets('shows each card with its placeholder details', (tester) async {
      await pumpHome(tester);
      await tester.pumpAndSettle();

      // Trending: rating with a decimal comma and a "By creator" line.
      expect(
        find.descendant(
          of: find.byType(MealTrendingCard).first,
          matching: find.textContaining(RegExp(r'^\d,\d$')),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(MealTrendingCard).first,
          matching: find.textContaining('By '),
        ),
        findsOneWidget,
      );
      // Popular: cook time.
      expect(
        find.descendant(
          of: find.byType(MealPopularCard).first,
          matching: find.textContaining(RegExp(r'^\d+ Mins$')),
        ),
        findsOneWidget,
      );
    });

    testWidgets('limits the popular carousel to ten meals', (tester) async {
      repository = await setUpDependencies(
        repository: FakeMealRepository(mealsPerCategory: 25),
      );
      await pumpHome(tester);
      await tester.pumpAndSettle();

      // Only the visible cards are built, so scroll the row to its end.
      final carousel = find.ancestor(
        of: find.byType(MealPopularCard).first,
        matching: find.byType(Scrollable),
      );
      await tester.drag(carousel.first, const Offset(-20000, 0));
      await tester.pumpAndSettle();

      expect(find.text('Beef dish 10'), findsOneWidget);
      expect(find.text('Beef dish 11'), findsNothing);
    });
  });

  group('choosing a category', () {
    testWidgets('highlights the tapped chip and shows its meals', (
      tester,
    ) async {
      await pumpHome(tester);
      await tester.pumpAndSettle();

      await tester.tap(chip('Lamb'));
      await tester.pumpAndSettle();

      expect(tester.getSemantics(chip('Lamb')), isSemantics(isSelected: true));
      expect(
        tester.getSemantics(chip('Beef')),
        isNot(isSemantics(isSelected: true)),
      );
      expect(find.text('Lamb dish 1'), findsOneWidget);
      expect(find.text('Beef dish 1'), findsNothing);
    });

    testWidgets('requests the new category from the repository', (
      tester,
    ) async {
      await pumpHome(tester);
      await tester.pumpAndSettle();
      repository.requestedCategories.clear();

      await tester.tap(chip('Lamb'));
      await tester.pumpAndSettle();

      expect(repository.requestedCategories, ['Lamb']);
    });

    testWidgets('does nothing when the selected chip is tapped again', (
      tester,
    ) async {
      await pumpHome(tester);
      await tester.pumpAndSettle();
      repository.requestedCategories.clear();

      await tester.tap(chip('Beef'));
      await tester.pumpAndSettle();

      expect(repository.requestedCategories, isEmpty);
    });

    testWidgets('highlights the chip before the meals arrive', (tester) async {
      await pumpHome(tester);
      await tester.pumpAndSettle();
      repository.holdMeals('Lamb');

      await tester.tap(chip('Lamb'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.getSemantics(chip('Lamb')), isSemantics(isSelected: true));
      expect(find.byType(MealPopularCardSkeleton), findsWidgets);
    });

    testWidgets('shows a message for a category with no meals', (tester) async {
      repository.mealsOverrides['Lamb'] = const Success([]);
      await pumpHome(tester);
      await tester.pumpAndSettle();

      await tester.tap(chip('Lamb'));
      await tester.pumpAndSettle();

      expect(find.text('No recipes in this category yet'), findsOneWidget);
    });

    testWidgets('shows an inline error with retry when only the meals fail', (
      tester,
    ) async {
      repository.mealsOverrides['Lamb'] = const Failed(NetworkFailure());
      await pumpHome(tester);
      await tester.pumpAndSettle();

      await tester.tap(chip('Lamb'));
      await tester.pumpAndSettle();

      expect(find.text(const NetworkFailure().message), findsOneWidget);
      // The rest of Home is still there.
      expect(find.text('Recent recipe'), findsOneWidget);
      expect(find.byType(AppErrorView), findsNothing);

      repository.mealsOverrides.remove('Lamb');
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(find.text('Lamb dish 1'), findsOneWidget);
    });
  });

  group('when the categories cannot be loaded', () {
    testWidgets('replaces the sections with one error and one retry', (
      tester,
    ) async {
      repository.categoriesResult = const Failed(NetworkFailure());
      await pumpHome(tester);
      await tester.pumpAndSettle();

      expect(find.byType(AppErrorView), findsOneWidget);
      expect(find.text(const NetworkFailure().message), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('Trending now 🔥'), findsNothing);
      expect(find.text('Popular category'), findsNothing);
      // The heading and search field stay.
      expect(find.text('Search recipes'), findsOneWidget);
    });

    testWidgets('Try again reloads everything', (tester) async {
      repository.categoriesResult = const Failed(NetworkFailure());
      await pumpHome(tester);
      await tester.pumpAndSettle();

      repository.categoriesResult = Success([
        for (final name in fakeCategoryNames) fakeCategory(name),
      ]);
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(find.byType(AppErrorView), findsNothing);
      expect(
        find.byType(CategoryChip),
        findsNWidgets(fakeCategoryNames.length),
      );
      expect(find.text('Beef dish 1'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(MealTrendingCard),
          matching: find.text('Chicken dish 1'),
        ),
        findsOneWidget,
      );
    });
  });

  group('when the trending meals cannot be loaded', () {
    testWidgets('shows inline errors in the two carousels, not a page error', (
      tester,
    ) async {
      repository.mealsOverrides['Chicken'] = const Failed(TimeoutFailure());
      await pumpHome(tester);
      await tester.pumpAndSettle();

      expect(find.byType(AppErrorView), findsNothing);
      expect(find.text(const TimeoutFailure().message), findsNWidgets(2));
      // Popular category is independent and still loads.
      expect(find.text('Beef dish 1'), findsOneWidget);
    });
  });

  testWidgets('tapping the search field opens the Search tab', (tester) async {
    final shell = await pumpHome(tester);
    await tester.pumpAndSettle();
    expect(shell.state, ShellTab.home);

    await tester.tap(find.text('Search recipes'));
    await tester.pump();

    expect(shell.state, ShellTab.search);
  });

  group('layout', () {
    for (final width in [320.0, 375.0, 430.0]) {
      testWidgets('has no overflow at ${width.toInt()} wide, loaded', (
        tester,
      ) async {
        await pumpHome(tester, width: width, height: 812);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('has no overflow at ${width.toInt()} wide, scrolled to the '
          'end', (tester) async {
        await pumpHome(tester, width: width, height: 812);
        await tester.pumpAndSettle();

        await tester.scrollUntilVisible(
          find.text('Popular creators'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('has no overflow at ${width.toInt()} wide, loading', (
        tester,
      ) async {
        repository.holdCategories();
        await pumpHome(tester, width: width, height: 812);
        await tester.pump(const Duration(milliseconds: 100));

        expect(tester.takeException(), isNull);
      });

      testWidgets('has no overflow at ${width.toInt()} wide, on error', (
        tester,
      ) async {
        repository.categoriesResult = const Failed(NetworkFailure());
        await pumpHome(tester, width: width, height: 812);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('keeps the last section clear of the navigation bar', (
      tester,
    ) async {
      await pumpHome(tester, height: 812);
      await tester.pumpAndSettle();

      await tester.drag(find.byType(Scrollable).first, const Offset(0, -3000));
      await tester.pumpAndSettle();

      // Fully scrolled, the creators' names must end above the 86 px bar.
      final names = find.text('Troyan\nSmith');
      expect(names, findsOneWidget);
      expect(tester.getBottomLeft(names).dy, lessThanOrEqualTo(812 - 86));
    });
  });
}
