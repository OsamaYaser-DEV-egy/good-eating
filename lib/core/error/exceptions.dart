/// Thrown by the data layer when a response is not shaped as expected.
final class ParsingException implements Exception {
  const ParsingException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'ParsingException: $message';
}

/// Thrown by the data layer when local storage cannot be read or written.
final class CacheException implements Exception {
  const CacheException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'CacheException: $message';
}
