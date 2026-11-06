import 'package:equatable/equatable.dart';

import 'package:good_eating/core/utils/result.dart';

/// A single unit of business logic. Presentation talks to use cases, never to
/// repositories or data sources directly.
// ignore: one_member_abstracts
abstract interface class UseCase<Out, Params> {
  Future<Result<Out>> call(Params params);
}

/// Parameter for use cases that need no input.
final class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => const [];
}
