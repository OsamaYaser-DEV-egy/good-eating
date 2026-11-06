import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/core/error/failure.dart';
import 'package:good_eating/core/utils/formatters.dart';
import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/core/utils/ui_placeholders.dart';
import 'package:good_eating/core/widgets/app_error_view.dart';
import 'package:good_eating/core/widgets/screen_header.dart';
import 'package:good_eating/features/meal_details/presentation/widgets/ingredient_tile.dart';
import 'package:good_eating/features/meal_details/presentation/widgets/meal_details_skeleton.dart';
import 'package:good_eating/features/meals/domain/entities/ingredient.dart';

import '../../helpers/fake_meal_repository.dart';
import '../../helpers/pump_meal_details.dart';
import '../../helpers/test_dependencies.dart';

void main() {
  late FakeMealRepository repository;

  setUp(() async {
    repository = await setUpDependencies();
  });

  Finder title(String name) =>
      find.descendant(of: find.byType(ScreenHeader), matching: find.text(name));

  Finder hero() => find.byWidgetPredicate(
    (widget) => widget is Hero && widget.tag == testHeroTag,
  );

  group('before the recipe has loaded', () {
    testWidgets('shows the name, photo, rating and creator straight away', (
      tester,
    ) async {
      repository.holdDetails('Chicken-1');
      await pumpMealDetails(tester);
      await tester.pump(const Duration(milliseconds: 100));

      final creator = UiPlaceholders.creator('Chicken-1');
      expect(title('Chicken dish 1'), findsOneWidget);
      expect(hero(), findsOneWidget);
      expect(
        find.text(Formatters.rating(UiPlaceholders.rating('Chicken-1'))),
        findsOneWidget,
      );
      expect(
        find.text(
          Formatters.reviewCount(UiPlaceholders.reviewCount('Chicken-1')),
        ),
        findsOneWidget,
      );
      expect(find.text(creator.name), findsOneWidget);
      expect(find.text(creator.location), findsOneWidget);
      expect(find.text('Follow'), findsOneWidget);
    });

    testWidgets('shows a skeleton where the recipe will go', (tester) async {
      repository.holdDetails('Chicken-1');
      await pumpMealDetails(tester);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(MealDetailsContentSkeleton), findsOneWidget);
      expect(find.text('Ingredients'), findsNothing);
      expect(find.text('Instructions'), findsNothing);
      expect(find.byType(AppErrorView), findsNothing);
    });

    testWidgets('offers no video yet, because it may not have one', (
      tester,
    ) async {
      repository.holdDetails('Chicken-1');
      await pumpMealDetails(tester);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.bySemanticsLabel('Play video'), findsNothing);
      expect(find.text('Watch on YouTube'), findsNothing);
    });
  });

  group('once loaded', () {
    testWidgets('shows the country and category', (tester) async {
      await pumpMealDetails(tester);
      await tester.pumpAndSettle();

      expect(find.text('Italian'), findsOneWidget);
      expect(find.text('Chicken'), findsOneWidget);
      expect(find.byType(MealDetailsContentSkeleton), findsNothing);
    });

    testWidgets('lists every ingredient with its quantity', (tester) async {
      await pumpMealDetails(tester);
      await tester.pumpAndSettle();

      expect(find.text('Ingredients'), findsOneWidget);
      expect(find.text('3 items'), findsOneWidget);
      expect(find.byType(IngredientTile), findsNWidgets(3));
      expect(find.text('flour'), findsOneWidget);
      expect(find.text('200g'), findsOneWidget);
      expect(find.text('eggs'), findsOneWidget);
      // "2" is also step badge 2, so look only inside the ingredient rows.
      expect(
        find.descendant(
          of: find.byType(IngredientTile),
          matching: find.text('2'),
        ),
        findsOneWidget,
      );
      expect(find.text('milk'), findsOneWidget);
    });

    testWidgets('says "1 item" for a single ingredient', (tester) async {
      repository.detailsOverrides['Chicken-1'] = Success(
        fakeMealDetail(
          'Chicken-1',
          ingredients: const [Ingredient(name: 'salt', measure: '1 pinch')],
        ),
      );
      await pumpMealDetails(tester);
      await tester.pumpAndSettle();

      expect(find.text('1 item'), findsOneWidget);
    });

    testWidgets('numbers the instruction steps in order', (tester) async {
      await pumpMealDetails(tester);
      await tester.pumpAndSettle();

      expect(find.text('Instructions'), findsOneWidget);
      expect(find.text('Mix everything.'), findsOneWidget);
      expect(find.text('Bake it.'), findsOneWidget);
      expect(find.text('Serve warm.'), findsOneWidget);
      expect(find.bySemanticsLabel('Step 1'), findsOneWidget);
      expect(find.bySemanticsLabel('Step 3'), findsOneWidget);
      expect(find.bySemanticsLabel('Step 4'), findsNothing);

      // Steps are laid out top to bottom in recipe order.
      final first = tester.getTopLeft(find.text('Mix everything.')).dy;
      final second = tester.getTopLeft(find.text('Bake it.')).dy;
      final third = tester.getTopLeft(find.text('Serve warm.')).dy;
      expect(first, lessThan(second));
      expect(second, lessThan(third));
    });

    testWidgets('shows the ingredients above the instructions', (tester) async {
      await pumpMealDetails(tester);
      await tester.pumpAndSettle();

      expect(
        tester.getTopLeft(find.text('Ingredients')).dy,
        lessThan(tester.getTopLeft(find.text('Instructions')).dy),
      );
    });

    testWidgets('keeps the hero photo in place after loading', (tester) async {
      await pumpMealDetails(tester);
      await tester.pumpAndSettle();

      expect(hero(), findsOneWidget);
    });

    testWidgets('shows a heart in the header, not yet responding', (
      tester,
    ) async {
      await pumpMealDetails(tester);
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Add to favorites'), findsOneWidget);
    });
  });

  group('with missing data', () {
    testWidgets('leaves out the Ingredients section when there are none', (
      tester,
    ) async {
      repository.detailsOverrides['Chicken-1'] = Success(
        fakeMealDetail('Chicken-1', ingredients: const []),
      );
      await pumpMealDetails(tester);
      await tester.pumpAndSettle();

      expect(find.text('Ingredients'), findsNothing);
      expect(find.text('Instructions'), findsOneWidget);
    });

    testWidgets('leaves out the Instructions section when there are none', (
      tester,
    ) async {
      repository.detailsOverrides['Chicken-1'] = Success(
        fakeMealDetail('Chicken-1', instructions: ''),
      );
      await pumpMealDetails(tester);
      await tester.pumpAndSettle();

      expect(find.text('Instructions'), findsNothing);
      expect(find.text('Ingredients'), findsOneWidget);
    });

    testWidgets('shows only the category when the country is missing', (
      tester,
    ) async {
      repository.detailsOverrides['Chicken-1'] = Success(
        fakeMealDetail('Chicken-1', area: null),
      );
      await pumpMealDetails(tester);
      await tester.pumpAndSettle();

      expect(find.text('Chicken'), findsOneWidget);
      expect(find.text('Italian'), findsNothing);
    });

    testWidgets('shows no measure for an ingredient that has none', (
      tester,
    ) async {
      repository.detailsOverrides['Chicken-1'] = Success(
        fakeMealDetail(
          'Chicken-1',
          ingredients: const [Ingredient(name: 'salt', measure: '')],
        ),
      );
      await pumpMealDetails(tester);
      await tester.pumpAndSettle();

      expect(find.text('salt'), findsOneWidget);
      final tile = find.byType(IngredientTile);
      expect(
        find.descendant(of: tile, matching: find.byType(Text)),
        findsOneWidget,
        reason: 'only the name, no empty measure',
      );
    });
  });

  group('the video', () {
    testWidgets('a recipe with a video shows a play button and a button', (
      tester,
    ) async {
      await pumpMealDetails(tester);
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Play video'), findsOneWidget);
      expect(find.text('Watch on YouTube'), findsOneWidget);
    });

    testWidgets('a recipe without a video shows neither', (tester) async {
      repository.detailsOverrides['Chicken-1'] = Success(
        fakeMealDetail('Chicken-1', youtubeUrl: null),
      );
      await pumpMealDetails(tester);
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Play video'), findsNothing);
      expect(find.text('Watch on YouTube'), findsNothing);
    });

    testWidgets('the Watch button opens the recipe video', (tester) async {
      await pumpMealDetails(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Watch on YouTube'));
      await tester.pump();

      expect(fakeLinkLauncher.opened, [
        'https://www.youtube.com/watch?v=abc123',
      ]);
    });

    testWidgets('tapping the play button opens the same video', (tester) async {
      await pumpMealDetails(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Play video'));
      await tester.pump();

      expect(fakeLinkLauncher.opened, [
        'https://www.youtube.com/watch?v=abc123',
      ]);
    });

    testWidgets('says so when the video cannot be opened', (tester) async {
      fakeLinkLauncher.succeeds = false;
      await pumpMealDetails(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Watch on YouTube'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Could not open the video.'), findsOneWidget);
    });

    testWidgets('says nothing when the video opens', (tester) async {
      await pumpMealDetails(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Watch on YouTube'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Could not open the video.'), findsNothing);
    });
  });

  group('when the recipe cannot be loaded', () {
    testWidgets('keeps the header and shows the error with Try again', (
      tester,
    ) async {
      repository.detailsOverrides['Chicken-1'] = const Failed(NetworkFailure());
      await pumpMealDetails(tester);
      await tester.pumpAndSettle();

      expect(find.byType(AppErrorView), findsOneWidget);
      expect(find.text(const NetworkFailure().message), findsOneWidget);
      expect(title('Chicken dish 1'), findsOneWidget);
      expect(hero(), findsOneWidget);
      expect(find.text('Ingredients'), findsNothing);
    });

    testWidgets('explains a recipe that no longer exists', (tester) async {
      repository.detailsOverrides['Chicken-1'] = const Failed(
        NotFoundFailure(),
      );
      await pumpMealDetails(tester);
      await tester.pumpAndSettle();

      expect(find.text(const NotFoundFailure().message), findsOneWidget);
    });

    testWidgets('Try again reloads the same recipe and recovers', (
      tester,
    ) async {
      repository.detailsOverrides['Chicken-1'] = const Failed(TimeoutFailure());
      await pumpMealDetails(tester);
      await tester.pumpAndSettle();
      repository.detailsOverrides.remove('Chicken-1');

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(repository.requestedDetails, ['Chicken-1', 'Chicken-1']);
      expect(find.byType(AppErrorView), findsNothing);
      expect(find.text('Ingredients'), findsOneWidget);
      expect(find.text('flour'), findsOneWidget);
    });
  });

  group('layout', () {
    const longTitle =
        'How to make an extremely long titled recipe that wraps over lines';
    final stress = fakeMealDetail(
      'Chicken-1',
      ingredients: const [
        Ingredient(
          name: 'finely chopped fresh flat-leaf parsley leaves and stems',
          measure: 'a generous handful, roughly 1/2 cup packed tightly',
        ),
        Ingredient(name: 'salt', measure: '1 pinch'),
        Ingredient(name: 'extra virgin olive oil', measure: ''),
      ],
      instructions: [
        for (var i = 1; i <= 12; i++)
          'Step $i: ${List.filled(18, 'combine thoroughly').join(', ')}.',
      ].join('\r\n'),
    );

    for (final width in [320.0, 375.0, 430.0]) {
      final label = width.toInt();

      testWidgets('has no overflow at $label wide, with long text', (
        tester,
      ) async {
        repository.detailsOverrides['Chicken-1'] = Success(stress);
        await pumpMealDetails(tester, width: width, name: longTitle);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('has no overflow at $label wide, loading', (tester) async {
        repository.holdDetails('Chicken-1');
        await pumpMealDetails(tester, width: width, name: longTitle);
        await tester.pump(const Duration(milliseconds: 300));

        expect(tester.takeException(), isNull);
      });

      testWidgets('has no overflow at $label wide, on error', (tester) async {
        repository.detailsOverrides['Chicken-1'] = const Failed(
          NetworkFailure(),
        );
        await pumpMealDetails(tester, width: width);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('has no overflow at $label wide, plain recipe', (
        tester,
      ) async {
        await pumpMealDetails(tester, width: width);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('scrolls to the Watch button and keeps it clear of the edge', (
      tester,
    ) async {
      repository.detailsOverrides['Chicken-1'] = Success(stress);
      await pumpMealDetails(tester, height: 812);
      await tester.pumpAndSettle();

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -20000),
      );
      await tester.pumpAndSettle();

      final button = tester.getRect(find.text('Watch on YouTube'));
      expect(button.bottom, lessThanOrEqualTo(812 - 24));
      expect(tester.takeException(), isNull);
    });

    testWidgets('sizes the photo to the design: 335 by 200 at 375 wide', (
      tester,
    ) async {
      await pumpMealDetails(tester);
      await tester.pumpAndSettle();

      final size = tester.getSize(hero());
      expect(size.width, closeTo(335, 0.5));
      expect(size.height, closeTo(200, 0.5));
    });

    testWidgets('lays ingredient rows 76 high, 12 apart', (tester) async {
      await pumpMealDetails(tester);
      await tester.pumpAndSettle();

      final first = tester.getRect(find.byType(IngredientTile).at(0));
      final second = tester.getRect(find.byType(IngredientTile).at(1));
      expect(first.height, 76);
      expect(second.top - first.bottom, 12);
      expect(first.left, 20);
      expect(first.width, 335);
    });
  });
}
