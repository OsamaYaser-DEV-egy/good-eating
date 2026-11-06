import 'package:good_eating/core/usecase/use_case.dart';
import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/features/onboarding/domain/repositories/onboarding_repository.dart';

final class IsOnboardingCompleted implements UseCase<bool, NoParams> {
  const IsOnboardingCompleted(this._repository);

  final OnboardingRepository _repository;

  @override
  Future<Result<bool>> call(NoParams params) => _repository.isCompleted();
}
