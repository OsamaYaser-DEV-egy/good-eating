import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/core/error/failure.dart';
import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/core/widgets/app_empty_view.dart';
import 'package:good_eating/core/widgets/app_error_view.dart';
import 'package:good_eating/core/widgets/favorite_heart_button.dart';
import 'package:good_eating/core/widgets/screen_header.dart';
import 'package:good_eating/features/favorites/presentation/widgets/favorites_list.dart';
import 'package:good_eating/features/meal_details/presentation/pages/meal_details_page.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';
import 'package:good_eating/features/meals/presentation/widgets/meal_card_list_skeleton.dart';
import 'package:good_eating/features/meals/presentation/widgets/meal_trending_card.dart';
import 'package:good_eating/features/search/presentation/widgets/search_field.dart';

import '../../helpers/fake_favorites_repository.dart';
import '../../helpers/fake_meal_repository.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_dependencies.dart';

const _pause = Duration(milliseconds: 300);

/// The one text field in the app, even while its tab is hidden.
Finder _field() => find.byType(TextField, skipOffstage: false);

bool _fieldHasFocus(WidgetTester tester) =>
    tester.widget<TextField>(_field()).focusNode!.hasFocus;

Future<void> _openSearchTab(WidgetTester tester) async {
  await tester.tap(find.bySemanticsLabel('Search'));
  await tester.pumpAndSettle();
}

/// Types [text] and waits out the pause so the search runs and settles.
Future<void> _searchFor(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pump(_pause);
  await tester.pumpAndSettle();
}

Finder _heartOn(String name) => find.descendant(
  of: find.ancestor(
    of: find.text(name),
    matching: find.byType(MealTrendingCard),
  ),
  matching: find.byType(FavoriteHeartButton),
);

void main() {
  late FakeMealRepository repository;

  setUp(() async {
    repository = await setUpDependencies();
  });

  group('the keyboard', () {
    testWidgets('is not raised at launch, while Search is hidden', (
      tester,
    ) async {
      await pumpApp(tester);

      expect(_fieldHasFocus(tester), isFalse);
    });

    testWidgets('appears when the Search tab is opened', (tester) async {
      await pumpApp(tester);

      await _openSearchTab(tester);

      expect(_fieldHasFocus(tester), isTrue);
    });

    testWidgets('goes away when the user leaves the tab', (tester) async {
      await pumpApp(tester);
      await _openSearchTab(tester);

      await tester.tap(find.bySemanticsLabel('Home'));
      await tester.pumpAndSettle();

      expect(_fieldHasFocus(tester), isFalse);
    });

    testWidgets('appears when the Home search box is tapped', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('Search recipes'));
      await tester.pumpAndSettle();

      expect(find.byType(SearchField), findsOneWidget);
      expect(_fieldHasFocus(tester), isTrue);
    });
  });

  group('before searching', () {
    testWidgets('invites the user to type', (tester) async {
      await pumpApp(tester);
      await _openSearchTab(tester);

      expect(find.byType(AppEmptyView), findsOneWidget);
      expect(find.text('Search for a recipe'), findsOneWidget);
      expect(repository.requestedSearches, isEmpty);
    });

    testWidgets('shows no clear button on an empty field', (tester) async {
      await pumpApp(tester);
      await _openSearchTab(tester);

      expect(find.byTooltip('Clear'), findsNothing);
    });
  });

  group('typing', () {
    testWidgets('waits for a pause before asking the server', (tester) async {
      await pumpApp(tester);
      await _openSearchTab(tester);

      await tester.enterText(find.byType(TextField), 'soup');
      await tester.pump(_pause - const Duration(milliseconds: 100));
      expect(repository.requestedSearches, isEmpty);

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      expect(repository.requestedSearches, ['soup']);
    });

    testWidgets('shows the matches as cards', (tester) async {
      await pumpApp(tester);
      await _openSearchTab(tester);

      await _searchFor(tester, 'soup');

      expect(find.byType(MealTrendingCard), findsNWidgets(3));
      expect(find.text('soup dish 1'), findsOneWidget);
      expect(find.text('soup dish 3'), findsOneWidget);
      expect(find.byType(AppEmptyView), findsNothing);
    });

    testWidgets('a word typed letter by letter makes one request', (
      tester,
    ) async {
      await pumpApp(tester);
      await _openSearchTab(tester);

      for (final text in ['s', 'so', 'sou', 'soup']) {
        await tester.enterText(find.byType(TextField), text);
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pump(_pause);
      await tester.pumpAndSettle();

      expect(repository.requestedSearches, ['soup']);
    });

    testWidgets('the keyboard search key searches without waiting', (
      tester,
    ) async {
      await pumpApp(tester);
      await _openSearchTab(tester);

      await tester.enterText(find.byType(TextField), 'soup');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(repository.requestedSearches, ['soup']);
      expect(find.text('soup dish 1'), findsOneWidget);
    });

    testWidgets('shows a skeleton while the request is running', (
      tester,
    ) async {
      final held = repository.holdSearch('soup');
      await pumpApp(tester);
      await _openSearchTab(tester);

      await tester.enterText(find.byType(TextField), 'soup');
      await tester.pump(_pause);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(MealCardListSkeleton), findsOneWidget);
      expect(find.byType(MealTrendingCard), findsNothing);

      held.complete(Success([fakeMeal('soup', 1)]));
      await tester.pumpAndSettle();
      expect(find.text('soup dish 1'), findsOneWidget);
    });

    testWidgets('replaces old results with new ones', (tester) async {
      await pumpApp(tester);
      await _openSearchTab(tester);
      await _searchFor(tester, 'soup');

      await _searchFor(tester, 'pie');

      expect(find.text('pie dish 1'), findsOneWidget);
      expect(find.text('soup dish 1'), findsNothing);
    });
  });

  group('nothing found', () {
    testWidgets('shows a friendly message, not an error', (tester) async {
      await pumpApp(tester);
      await _openSearchTab(tester);

      await _searchFor(tester, 'zzzz');

      expect(find.byType(AppEmptyView), findsOneWidget);
      expect(find.text('No recipes found'), findsOneWidget);
      expect(find.textContaining('"zzzz"'), findsOneWidget);
      expect(find.byType(AppErrorView), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the next search works normally', (tester) async {
      await pumpApp(tester);
      await _openSearchTab(tester);
      await _searchFor(tester, 'zzzz');

      await _searchFor(tester, 'soup');

      expect(find.text('No recipes found'), findsNothing);
      expect(find.text('soup dish 1'), findsOneWidget);
    });
  });

  group('when the search fails', () {
    testWidgets('shows the error with Try again, and the field stays', (
      tester,
    ) async {
      repository.searchOverrides['soup'] = const Failed(NetworkFailure());
      await pumpApp(tester);
      await _openSearchTab(tester);

      await _searchFor(tester, 'soup');

      expect(find.byType(AppErrorView), findsOneWidget);
      expect(find.text(const NetworkFailure().message), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Try again repeats the same search and recovers', (
      tester,
    ) async {
      repository.searchOverrides['soup'] = const Failed(TimeoutFailure());
      await pumpApp(tester);
      await _openSearchTab(tester);
      await _searchFor(tester, 'soup');
      repository.searchOverrides.remove('soup');

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(repository.requestedSearches, ['soup', 'soup']);
      expect(find.byType(AppErrorView), findsNothing);
      expect(find.text('soup dish 1'), findsOneWidget);
    });
  });

  group('the clear button', () {
    testWidgets('appears once there is text', (tester) async {
      await pumpApp(tester);
      await _openSearchTab(tester);

      await tester.enterText(find.byType(TextField), 'so');
      await tester.pump();

      expect(find.byTooltip('Clear'), findsOneWidget);
    });

    testWidgets('empties the field and returns to the invitation', (
      tester,
    ) async {
      await pumpApp(tester);
      await _openSearchTab(tester);
      await _searchFor(tester, 'soup');

      await tester.tap(find.byTooltip('Clear'));
      await tester.pumpAndSettle();

      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      expect(find.text('Search for a recipe'), findsOneWidget);
      expect(find.byType(MealTrendingCard), findsNothing);
      expect(find.byTooltip('Clear'), findsNothing);
    });

    testWidgets('keeps the keyboard up and sends no request', (tester) async {
      await pumpApp(tester);
      await _openSearchTab(tester);
      await _searchFor(tester, 'soup');
      repository.requestedSearches.clear();

      await tester.tap(find.byTooltip('Clear'));
      await tester.pump(_pause * 2);
      await tester.pumpAndSettle();

      expect(_fieldHasFocus(tester), isTrue);
      expect(repository.requestedSearches, isEmpty);
    });
  });

  group('with the rest of the app', () {
    testWidgets('a result opens its meal, and back keeps the search', (
      tester,
    ) async {
      await pumpApp(tester);
      await _openSearchTab(tester);
      await _searchFor(tester, 'soup');

      await tester.tap(find.text('soup dish 2'));
      await tester.pumpAndSettle();

      expect(find.byType(MealDetailsPage), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ScreenHeader),
          matching: find.text('soup dish 2'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();

      expect(find.text('soup dish 2'), findsOneWidget);
      expect(repository.requestedSearches, [
        'soup',
      ], reason: 'not searched again');
    });

    testWidgets('hearting a result saves it to the Saved tab', (tester) async {
      await pumpApp(tester);
      await _openSearchTab(tester);
      await _searchFor(tester, 'soup');

      await tester.tap(_heartOn('soup dish 1'));
      await tester.pumpAndSettle();

      expect(
        tester.widget<FavoriteHeartButton>(_heartOn('soup dish 1')).isFavorite,
        isTrue,
      );
      await tester.tap(find.bySemanticsLabel('Saved'));
      await tester.pumpAndSettle();
      expect(
        [
          for (final card in tester.widgetList<MealTrendingCard>(
            find.descendant(
              of: find.byType(FavoritesList),
              matching: find.byType(MealTrendingCard),
            ),
          ))
            card.meal.name,
        ],
        ['soup dish 1'],
      );
    });

    testWidgets('a meal that is already saved shows a filled heart', (
      tester,
    ) async {
      const saved = MealSummary(
        id: 'soup-1',
        name: 'soup dish 1',
        thumbUrl: '',
      );
      await setUpDependencies(
        favorites: FavoritesRepositoryFake(initial: [saved]),
      );
      await pumpApp(tester);
      await _openSearchTab(tester);

      await _searchFor(tester, 'soup');

      expect(
        tester.widget<FavoriteHeartButton>(_heartOn('soup dish 1')).isFavorite,
        isTrue,
      );
      expect(
        tester.widget<FavoriteHeartButton>(_heartOn('soup dish 2')).isFavorite,
        isFalse,
      );
    });

    testWidgets('keeps the text and results while another tab is open', (
      tester,
    ) async {
      await pumpApp(tester);
      await _openSearchTab(tester);
      await _searchFor(tester, 'soup');

      await tester.tap(find.bySemanticsLabel('Saved'));
      await tester.pumpAndSettle();
      await _openSearchTab(tester);

      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'soup',
      );
      expect(find.text('soup dish 1'), findsOneWidget);
      expect(repository.requestedSearches, ['soup']);
    });
  });

  group('layout', () {
    for (final width in [320.0, 375.0, 430.0]) {
      final label = width.toInt();

      testWidgets('has no overflow at $label wide, idle', (tester) async {
        await pumpApp(tester, width: width);
        await _openSearchTab(tester);
        expect(tester.takeException(), isNull);
      });

      testWidgets('has no overflow at $label wide, with results', (
        tester,
      ) async {
        await pumpApp(tester, width: width);
        await _openSearchTab(tester);
        await _searchFor(tester, 'soup');
        expect(tester.takeException(), isNull);
      });

      testWidgets('has no overflow at $label wide, nothing found', (
        tester,
      ) async {
        await pumpApp(tester, width: width);
        await _openSearchTab(tester);
        await _searchFor(tester, 'zzzz');
        expect(tester.takeException(), isNull);
      });

      testWidgets('has no overflow at $label wide, on error', (tester) async {
        repository.searchOverrides['soup'] = const Failed(NetworkFailure());
        await pumpApp(tester, width: width);
        await _openSearchTab(tester);
        await _searchFor(tester, 'soup');
        expect(tester.takeException(), isNull);
      });

      testWidgets('has no overflow at $label wide, loading', (tester) async {
        repository.holdSearch('soup');
        await pumpApp(tester, width: width);
        await _openSearchTab(tester);
        await tester.enterText(find.byType(TextField), 'soup');
        await tester.pump(_pause);
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('draws the field 44 high and as wide as the design', (
      tester,
    ) async {
      await pumpApp(tester);
      await _openSearchTab(tester);

      final box = tester.getRect(find.byType(TextField));
      expect(box.height, 44);
      expect(box.left, 20);
      expect(box.width, 335);
    });

    testWidgets('has no overflow with the keyboard open', (tester) async {
      await pumpApp(tester, height: 812);
      await _openSearchTab(tester);
      await _searchFor(tester, 'soup');

      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('keeps the last result clear of the navigation bar', (
      tester,
    ) async {
      repository.searchOverrides['soup'] = Success([
        for (var i = 1; i <= 8; i++) fakeMeal('soup', i),
      ]);
      await pumpApp(tester, height: 812);
      await _openSearchTab(tester);
      await _searchFor(tester, 'soup');

      await tester.drag(find.byType(ListView).first, const Offset(0, -20000));
      await tester.pumpAndSettle();

      final last = tester.getRect(find.byType(MealTrendingCard).last);
      expect(last.bottom, lessThanOrEqualTo(812 - 86));
    });
  });
}
