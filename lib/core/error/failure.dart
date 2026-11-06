import 'package:equatable/equatable.dart';

/// A user-presentable description of what went wrong.
///
/// Failures are plain values returned through `Result`. Raw exceptions never
/// leave the data layer; `ErrorMapper` is the single place that builds them.
sealed class Failure extends Equatable {
  const Failure(this.message, {this.cause});

  /// Safe to show to the user.
  final String message;

  /// The underlying error, kept for logging only and never shown in the UI.
  final Object? cause;

  @override
  List<Object?> get props => [message];
}

/// No connection, DNS failure or similar.
final class NetworkFailure extends Failure {
  const NetworkFailure({super.cause})
    : super('No internet connection. Check your network and try again.');
}

/// Connect or receive timeout.
final class TimeoutFailure extends Failure {
  const TimeoutFailure({super.cause})
    : super('The request took too long. Please try again.');
}

/// A 4xx/5xx response other than "not found".
final class ServerFailure extends Failure {
  const ServerFailure({this.statusCode, super.cause})
    : super('Something went wrong on our side. Please try again later.');

  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

/// A 404 response.
final class NotFoundFailure extends Failure {
  const NotFoundFailure({super.cause})
    : super('We could not find what you were looking for.');
}

/// The response was not shaped the way the models expect.
final class ParsingFailure extends Failure {
  const ParsingFailure({super.cause})
    : super('We received data we could not understand.');
}

/// Reading from or writing to local storage failed.
final class CacheFailure extends Failure {
  const CacheFailure({super.cause})
    : super('Could not read or save data on this device.');
}

/// Anything that does not fit a more specific failure.
final class UnknownFailure extends Failure {
  const UnknownFailure({super.cause})
    : super('Something unexpected happened. Please try again.');
}
