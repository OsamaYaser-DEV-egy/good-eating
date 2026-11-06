import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/core/error/failure.dart';
import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/core/widgets/app_empty_view.dart';
import 'package:good_eating/core/widgets/app_error_view.dart';
import 'package:good_eating/core/widgets/screen_header.dart';
import 'package:good_eating/features/category_meals/presentation/widgets/category_meals_grid.dart';
import 'package:good_eating/features/meals/presentation/widgets/category_chip.dart';
import 'package:good_eating/features/meals/presentation/widgets/meal_popular_card.dart';

import '../../helpers/fake_meal_repository.dart';
import '../../helpers/pump_category_meals.dart';
import '../../helpers/test_dependencies.dart';

void main() {
  late FakeMealRepository repository;

  setUp(() async {
    repository = await setUpDependencies();
  });

  Finder chip(String name) =>
      find.ancestor(of: find.text(name), matching: find.byType(CategoryChip));

  Finder title(String name) =>
      find.descendant(of: find.byType(ScreenHeader), matching: find.text(name));

  Finder gridScrollable() => find.descendant(
    of: find.byType(GridView),
    matching: find.byType(Scrollable),
  );

  group('opening', () {
    testWidgets('shows the category as the title and selects its chip', (
      tester,
    ) async {
      await pumpCategoryMeals(tester, category: 'Chicken');
      await tester.pumpAndSettle();

      expect(title('Chicken'), findsOneWidget);
      expect(
        tester.getSemantics(chip('Chicken')),
        isSemantics(isSelected: true),
      );
      expect(
        tester.getSemantics(chip('Beef')),
        isNot(isSemantics(isSelected: true)),
      );
    });

    testWidgets('loads only the requested category, not the first one', (
      tester,
    ) async {
      await pumpCategoryMeals(tester, category: 'Lamb');
      await tester.pumpAndSettle();

      expect(repository.requestedCategories, ['Lamb']);
    });

    testWidgets('lists every category as a chip', (tester) async {
      await pumpCategoryMeals(tester, category: 'Chicken');
      await tester.pumpAndSettle();

      expect(
        find.byType(CategoryChip),
        findsNWidgets(fakeCategoryNames.length),
      );
    });
  });

  group('while loading', () {
    testWidgets('keeps the header and chips and shows a skeleton grid', (
      tester,
    ) async {
      repository.holdMeals('Chicken');
      await pumpCategoryMeals(tester, category: 'Chicken');
      await tester.pump(const Duration(milliseconds: 300));

      expect(title('Chicken'), findsOneWidget);
      expect(find.byType(CategoryChip), findsWidgets);
      expect(find.byType(MealPopularCardSkeleton), findsWidgets);
      expect(find.byType(MealPopularCard), findsNothing);
      expect(find.byType(AppErrorView), findsNothing);
    });
  });

  group('the grid', () {
    testWidgets('has exactly two columns', (tester) async {
      await pumpCategoryMeals(tester, category: 'Chicken');
      await tester.pumpAndSettle();

      final grid = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, CategoryMealsGrid.columns);
      expect(CategoryMealsGrid.columns, 2);
    });

    testWidgets('places cards two to a row, then wraps', (tester) async {
      await pumpCategoryMeals(tester, category: 'Chicken');
      await tester.pumpAndSettle();

      final first = tester.getTopLeft(find.byType(MealPopularCard).at(0));
      final second = tester.getTopLeft(find.byType(MealPopularCard).at(1));
      final third = tester.getTopLeft(find.byType(MealPopularCard).at(2));

      expect(second.dy, first.dy, reason: 'first two share a row');
      expect(second.dx, greaterThan(first.dx));
      expect(third.dy, greaterThan(first.dy), reason: 'third wraps');
      expect(third.dx, first.dx);
    });

    testWidgets('splits the width evenly with a 16 px gap', (tester) async {
      await pumpCategoryMeals(tester, category: 'Chicken');
      await tester.pumpAndSettle();

      final first = tester.getRect(find.byType(MealPopularCard).at(0));
      final second = tester.getRect(find.byType(MealPopularCard).at(1));

      expect(first.left, 20);
      expect(second.right, 375 - 20);
      expect(first.width, second.width);
      expect(second.left - first.right, 16);
    });

    testWidgets('shows every meal in the category, not a preview', (
      tester,
    ) async {
      repository = await setUpDependencies(
        repository: FakeMealRepository(mealsPerCategory: 25),
      );
      await pumpCategoryMeals(tester, category: 'Chicken');
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Chicken dish 25'),
        300,
        scrollable: gridScrollable(),
      );

      expect(find.text('Chicken dish 25'), findsOneWidget);
    });

    testWidgets('keeps the chips pinned while the grid scrolls', (
      tester,
    ) async {
      repository = await setUpDependencies(
        repository: FakeMealRepository(mealsPerCategory: 25),
      );
      await pumpCategoryMeals(tester, category: 'Chicken');
      await tester.pumpAndSettle();
      final before = tester.getTopLeft(chip('Chicken'));

      await tester.drag(find.byType(GridView), const Offset(0, -1500));
      await tester.pumpAndSettle();

      expect(tester.getTopLeft(chip('Chicken')), before);
    });
  });

  group('choosing another category', () {
    testWidgets('updates the title, the chips and the meals', (tester) async {
      await pumpCategoryMeals(tester, category: 'Chicken');
      await tester.pumpAndSettle();

      await tester.tap(chip('Lamb'));
      await tester.pumpAndSettle();

      expect(title('Lamb'), findsOneWidget);
      expect(title('Chicken'), findsNothing);
      expect(tester.getSemantics(chip('Lamb')), isSemantics(isSelected: true));
      expect(find.text('Lamb dish 1'), findsOneWidget);
      expect(find.text('Chicken dish 1'), findsNothing);
      expect(repository.requestedCategories, ['Chicken', 'Lamb']);
    });

    testWidgets('highlights the chip and shows skeletons before meals arrive', (
      tester,
    ) async {
      await pumpCategoryMeals(tester, category: 'Chicken');
      await tester.pumpAndSettle();
      repository.holdMeals('Lamb');

      await tester.tap(chip('Lamb'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.getSemantics(chip('Lamb')), isSemantics(isSelected: true));
      expect(find.byType(MealPopularCardSkeleton), findsWidgets);
    });

    testWidgets('does nothing when the current chip is tapped again', (
      tester,
    ) async {
      await pumpCategoryMeals(tester, category: 'Chicken');
      await tester.pumpAndSettle();
      repository.requestedCategories.clear();

      await tester.tap(chip('Chicken'));
      await tester.pumpAndSettle();

      expect(repository.requestedCategories, isEmpty);
    });
  });

  group('empty and error states', () {
    testWidgets('an empty category shows a friendly message, not an error', (
      tester,
    ) async {
      repository.mealsOverrides['Goat'] = const Success([]);
      await pumpCategoryMeals(tester, category: 'Goat');
      await tester.pumpAndSettle();

      expect(find.byType(AppEmptyView), findsOneWidget);
      expect(find.text('No recipes here yet'), findsOneWidget);
      expect(find.byType(AppErrorView), findsNothing);
      expect(find.byType(GridView), findsNothing);
    });

    testWidgets('a failed request shows the error with Try again', (
      tester,
    ) async {
      repository.mealsOverrides['Chicken'] = const Failed(NetworkFailure());
      await pumpCategoryMeals(tester, category: 'Chicken');
      await tester.pumpAndSettle();

      expect(find.byType(AppErrorView), findsOneWidget);
      expect(find.text(const NetworkFailure().message), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
      // The header and chips stay, so the user can still pick another one.
      expect(title('Chicken'), findsOneWidget);
      expect(find.byType(CategoryChip), findsWidgets);
    });

    testWidgets('Try again reloads the same category and recovers', (
      tester,
    ) async {
      repository.mealsOverrides['Chicken'] = const Failed(TimeoutFailure());
      await pumpCategoryMeals(tester, category: 'Chicken');
      await tester.pumpAndSettle();
      repository.mealsOverrides.remove('Chicken');
      repository.requestedCategories.clear();

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(repository.requestedCategories, ['Chicken']);
      expect(find.byType(AppErrorView), findsNothing);
      expect(find.text('Chicken dish 1'), findsOneWidget);
    });

    testWidgets('another chip still works after a failure', (tester) async {
      repository.mealsOverrides['Chicken'] = const Failed(NetworkFailure());
      await pumpCategoryMeals(tester, category: 'Chicken');
      await tester.pumpAndSettle();

      await tester.tap(chip('Lamb'));
      await tester.pumpAndSettle();

      expect(find.byType(AppErrorView), findsNothing);
      expect(find.text('Lamb dish 1'), findsOneWidget);
    });
  });

  group('layout', () {
    for (final width in [320.0, 375.0, 430.0]) {
      final label = width.toInt();

      testWidgets('has no overflow at $label wide, loaded', (tester) async {
        await pumpCategoryMeals(tester, category: 'Chicken', width: width);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('has no overflow at $label wide, scrolled to the end', (
        tester,
      ) async {
        repository = await setUpDependencies(
          repository: FakeMealRepository(mealsPerCategory: 25),
        );
        await pumpCategoryMeals(tester, category: 'Chicken', width: width);
        await tester.pumpAndSettle();

        await tester.drag(find.byType(GridView), const Offset(0, -20000));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('has no overflow at $label wide, loading', (tester) async {
        repository.holdMeals('Chicken');
        await pumpCategoryMeals(tester, category: 'Chicken', width: width);
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
      });

      testWidgets('has no overflow at $label wide, on error', (tester) async {
        repository.mealsOverrides['Chicken'] = const Failed(NetworkFailure());
        await pumpCategoryMeals(tester, category: 'Chicken', width: width);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('has no overflow at $label wide, empty', (tester) async {
        repository.mealsOverrides['Chicken'] = const Success([]);
        await pumpCategoryMeals(tester, category: 'Chicken', width: width);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('keeps the last row clear of the bottom edge', (tester) async {
      repository = await setUpDependencies(
        repository: FakeMealRepository(mealsPerCategory: 25),
      );
      await pumpCategoryMeals(tester, category: 'Chicken');
      await tester.pumpAndSettle();

      await tester.drag(find.byType(GridView), const Offset(0, -20000));
      await tester.pumpAndSettle();

      final last = tester.getRect(find.byType(MealPopularCard).last);
      expect(last.bottom, lessThanOrEqualTo(812 - 24));
    });
  });
}
