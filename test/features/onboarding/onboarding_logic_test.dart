import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_eating/bootstrap.dart';
import 'package:good_eating/core/error/exceptions.dart';
import 'package:good_eating/core/error/failure.dart';
import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/features/onboarding/data/datasources/onboarding_local_data_source.dart';
import 'package:good_eating/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:good_eating/features/onboarding/domain/usecases/complete_onboarding.dart';
import 'package:good_eating/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

import '../../helpers/fake_onboarding_repository.dart';
import '../../helpers/test_dependencies.dart';

/// A store that accepts reads but refuses every write, like a full disk.
class _RefusingStore extends InMemorySharedPreferencesStore {
  _RefusingStore() : super.empty();

  @override
  Future<bool> setValue(String valueType, String key, Object value) async =>
      false;
}

void main() {
  group('OnboardingCubit', () {
    late FakeOnboardingRepository repository;

    setUp(() => repository = FakeOnboardingRepository());

    OnboardingCubit build() =>
        OnboardingCubit(completeOnboarding: CompleteOnboarding(repository));

    test('starts ready', () {
      expect(build().state, OnboardingState.ready);
    });

    blocTest<OnboardingCubit, OnboardingState>(
      'saves, then is done',
      build: build,
      act: (cubit) => cubit.start(),
      expect: () => [OnboardingState.saving, OnboardingState.done],
      verify: (_) {
        expect(repository.markCalls, 1);
        expect(repository.completed, isTrue);
      },
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'still goes on when the flag cannot be saved',
      build: () {
        repository.markResult = const Failed(CacheFailure());
        return build();
      },
      act: (cubit) => cubit.start(),
      expect: () => [OnboardingState.saving, OnboardingState.done],
      verify: (_) => expect(repository.completed, isFalse),
    );

    test('a second tap while saving is ignored', () async {
      final hold = repository.holdMark();
      final cubit = build();
      addTearDown(cubit.close);

      final first = cubit.start();
      await cubit.start();
      await cubit.start();
      expect(cubit.state, OnboardingState.saving);

      hold.complete();
      await first;

      expect(repository.markCalls, 1, reason: 'saved once, however many taps');
      expect(cubit.state, OnboardingState.done);
    });

    test('a tap after it is done is ignored too', () async {
      final cubit = build();
      addTearDown(cubit.close);
      await cubit.start();

      await cubit.start();

      expect(repository.markCalls, 1);
    });

    test('does not emit after being closed', () async {
      final hold = repository.holdMark();
      final cubit = build();

      final saving = cubit.start();
      await cubit.close();
      hold.complete();
      await saving;

      expect(cubit.state, OnboardingState.saving);
    });
  });

  group('OnboardingLocalDataSourceImpl', () {
    Future<OnboardingLocalDataSourceImpl> sourceWith([
      Map<String, Object> initial = const {},
    ]) async {
      SharedPreferences.setMockInitialValues(initial);
      return OnboardingLocalDataSourceImpl(
        await SharedPreferences.getInstance(),
      );
    }

    test('is not completed on the very first launch', () async {
      expect((await sourceWith()).isCompleted(), isFalse);
    });

    test('remembers that it was completed', () async {
      final source = await sourceWith();
      await source.markCompleted();

      expect(source.isCompleted(), isTrue);
    });

    test('survives being read through a brand new instance', () async {
      await (await sourceWith()).markCompleted();

      final relaunched = OnboardingLocalDataSourceImpl(
        await SharedPreferences.getInstance(),
      );

      expect(relaunched.isCompleted(), isTrue);
    });

    test('stores under one stable key', () async {
      await (await sourceWith()).markCompleted();

      final preferences = await SharedPreferences.getInstance();
      expect(OnboardingLocalDataSourceImpl.storageKey, 'onboarding_completed');
      expect(preferences.getBool('onboarding_completed'), isTrue);
    });

    test('reports a CacheException when the store refuses the write', () async {
      SharedPreferences.resetStatic();
      SharedPreferencesStorePlatform.instance = _RefusingStore();
      final source = OnboardingLocalDataSourceImpl(
        await SharedPreferences.getInstance(),
      );

      expect(source.markCompleted, throwsA(isA<CacheException>()));
    });

    test('a value of the wrong type counts as not completed', () async {
      for (final value in <Object>['yes', 1, 'true']) {
        final source = await sourceWith({'onboarding_completed': value});
        expect(source.isCompleted(), isFalse, reason: '$value');
      }
    });
  });

  group('OnboardingRepositoryImpl', () {
    test('reports completion and saving through Result', () async {
      SharedPreferences.setMockInitialValues({});
      final repository = OnboardingRepositoryImpl(
        OnboardingLocalDataSourceImpl(await SharedPreferences.getInstance()),
      );

      expect((await repository.isCompleted() as Success<bool>).value, isFalse);
      expect(await repository.markCompleted(), isA<Success<void>>());
      expect((await repository.isCompleted() as Success<bool>).value, isTrue);
    });

    test('turns a failed write into a CacheFailure', () async {
      SharedPreferences.resetStatic();
      SharedPreferencesStorePlatform.instance = _RefusingStore();
      final repository = OnboardingRepositoryImpl(
        OnboardingLocalDataSourceImpl(await SharedPreferences.getInstance()),
      );

      final result = await repository.markCompleted();

      expect((result as Failed<void>).failure, isA<CacheFailure>());
    });
  });

  group('shouldShowOnboarding', () {
    test('is true on the very first launch', () async {
      await setUpDependencies();
      expect(await shouldShowOnboarding(), isTrue);
    });

    test('is false once the welcome screen has been completed', () async {
      await setUpDependencies(
        onboarding: FakeOnboardingRepository(completed: true),
      );
      expect(await shouldShowOnboarding(), isFalse);
    });

    test('stays false after a restart that kept the stored flag', () async {
      await setUpDependencies();
      expect(await shouldShowOnboarding(), isTrue);

      final cubit = OnboardingCubit(
        completeOnboarding: CompleteOnboarding(
          OnboardingRepositoryImpl(
            OnboardingLocalDataSourceImpl(
              await SharedPreferences.getInstance(),
            ),
          ),
        ),
      );
      await cubit.start();
      await cubit.close();

      await setUpDependencies(keepStorage: true);
      expect(await shouldShowOnboarding(), isFalse);
    });

    test('skips the welcome screen when the flag cannot be read', () async {
      await setUpDependencies(
        onboarding: FakeOnboardingRepository()
          ..isCompletedResult = const Failed(CacheFailure()),
      );
      expect(await shouldShowOnboarding(), isFalse);
    });
  });
}
