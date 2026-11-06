import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_eating/core/error/failure.dart';
import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/features/home/presentation/pages/home_page.dart';
import 'package:good_eating/features/onboarding/data/datasources/onboarding_local_data_source.dart';
import 'package:good_eating/features/onboarding/presentation/widgets/onboarding_background.dart';
import 'package:good_eating/features/onboarding/presentation/widgets/onboarding_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_meal_repository.dart';
import '../../helpers/fake_onboarding_repository.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_dependencies.dart';

const _headline = 'Let’s\nCooking';

void main() {
  late FakeMealRepository repository;

  setUp(() async {
    repository = await setUpDependencies();
  });

  group('the welcome screen', () {
    testWidgets('shows the headline, subtitle, premium line and button', (
      tester,
    ) async {
      await pumpApp(tester, showOnboarding: true);

      expect(find.text(_headline), findsOneWidget);
      expect(find.text('Find best recipes for cooking'), findsOneWidget);
      expect(find.textContaining('60k+ Premium recipes'), findsOneWidget);
      expect(find.text('Start cooking'), findsOneWidget);
    });

    testWidgets('draws without the photo, using a dark gradient', (
      tester,
    ) async {
      await pumpApp(tester, showOnboarding: true);

      expect(find.byType(OnboardingBackground), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('does not build the app underneath it', (tester) async {
      await pumpApp(tester, showOnboarding: true);

      expect(find.byType(HomePage, skipOffstage: false), findsNothing);
      expect(repository.requestedCategories, isEmpty);
    });

    testWidgets('has nothing to go back to', (tester) async {
      await pumpApp(tester, showOnboarding: true);

      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      expect(navigator.canPop(), isFalse);
    });
  });

  group('Start cooking', () {
    testWidgets('opens the app on Home', (tester) async {
      await pumpApp(tester, showOnboarding: true);

      await tester.tap(find.text('Start cooking'));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingView), findsNothing);
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text('Popular category'), findsOneWidget);
    });

    testWidgets('remembers that the welcome screen was seen', (tester) async {
      await pumpApp(tester, showOnboarding: true);

      await tester.tap(find.text('Start cooking'));
      await tester.pumpAndSettle();

      final preferences = await SharedPreferences.getInstance();
      expect(
        preferences.getBool(OnboardingLocalDataSourceImpl.storageKey),
        isTrue,
      );
    });

    testWidgets('leaves nothing to go back to', (tester) async {
      await pumpApp(tester, showOnboarding: true);
      await tester.tap(find.text('Start cooking'));
      await tester.pumpAndSettle();

      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      expect(navigator.canPop(), isFalse);
      expect(await navigator.maybePop(), isFalse);
    });

    testWidgets('a double tap opens the app once and saves once', (
      tester,
    ) async {
      final onboarding = FakeOnboardingRepository();
      await setUpDependencies(onboarding: onboarding);
      await pumpApp(tester, showOnboarding: true);

      await tester.tap(find.text('Start cooking'));
      await tester.tap(find.text('Start cooking'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(onboarding.markCalls, 1);
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('opens the app even if the flag cannot be saved', (
      tester,
    ) async {
      final onboarding = FakeOnboardingRepository();
      onboarding.markResult = const Failed(CacheFailure());
      await setUpDependencies(onboarding: onboarding);
      await pumpApp(tester, showOnboarding: true);

      await tester.tap(find.text('Start cooking'));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
    });
  });

  group('a normal launch', () {
    testWidgets('opens straight on Home, with no welcome screen', (
      tester,
    ) async {
      await pumpApp(tester);

      expect(find.byType(OnboardingView), findsNothing);
      expect(find.byType(HomePage), findsOneWidget);
    });
  });

  group('layout', () {
    for (final size in const [Size(320, 568), Size(375, 812), Size(430, 932)]) {
      testWidgets('has no overflow at ${size.width.toInt()} by '
          '${size.height.toInt()}', (tester) async {
        await pumpApp(
          tester,
          width: size.width,
          height: size.height,
          showOnboarding: true,
        );

        expect(tester.takeException(), isNull);
        expect(find.text('Start cooking'), findsOneWidget);
      });
    }

    testWidgets('keeps the button 205 wide and centred', (tester) async {
      await pumpApp(tester, height: 812, showOnboarding: true);

      final button = tester.getRect(find.byType(FilledButton));
      expect(button.width, 205);
      expect(button.center.dx, closeTo(375 / 2, 0.5));
    });

    testWidgets('centres the headline', (tester) async {
      await pumpApp(tester, height: 812, showOnboarding: true);

      final headline = tester.getRect(find.text(_headline));
      expect(headline.center.dx, closeTo(375 / 2, 1));
    });

    testWidgets('has no overflow with large text', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await pumpApp(tester, height: 812, showOnboarding: true);

      expect(tester.takeException(), isNull);
    });
  });
}
