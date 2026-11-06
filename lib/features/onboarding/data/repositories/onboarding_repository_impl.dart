import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/features/onboarding/data/datasources/onboarding_local_data_source.dart';
import 'package:good_eating/features/onboarding/domain/repositories/onboarding_repository.dart';

final class OnboardingRepositoryImpl implements OnboardingRepository {
  const OnboardingRepositoryImpl(this._local);

  final OnboardingLocalDataSource _local;

  @override
  Future<Result<bool>> isCompleted() async =>
      Result.guard(() async => _local.isCompleted());

  @override
  Future<Result<void>> markCompleted() => Result.guard(_local.markCompleted);
}
