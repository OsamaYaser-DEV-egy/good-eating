import 'package:good_eating/core/usecase/use_case.dart';
import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/features/onboarding/domain/repositories/onboarding_repository.dart';

final class CompleteOnboarding implements UseCase<void, NoParams> {
  const CompleteOnboarding(this._repository);

  final OnboardingRepository _repository;

  @override
  Future<Result<void>> call(NoParams params) => _repository.markCompleted();
}
