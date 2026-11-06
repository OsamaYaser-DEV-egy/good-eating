import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'package:good_eating/core/constants/api_constants.dart';

/// Answers every request from [responder] and records what was asked, so
/// tests can run real `Dio` code without touching the network.
final class FakeHttpClientAdapter implements HttpClientAdapter {
  FakeHttpClientAdapter(this._responder);

  /// Always replies 200 with [body] and the given content type.
  factory FakeHttpClientAdapter.ok(
    String body, {
    String contentType = 'application/json; charset=utf-8',
  }) => FakeHttpClientAdapter(
    (_) => ResponseBody.fromString(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: [contentType],
      },
    ),
  );

  /// Always replies with [statusCode] and an empty JSON object.
  factory FakeHttpClientAdapter.status(int statusCode) => FakeHttpClientAdapter(
    (_) => ResponseBody.fromString(
      '{}',
      statusCode,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    ),
  );

  final ResponseBody Function(RequestOptions options) _responder;

  /// Every request received, in order.
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return _responder(options);
  }

  @override
  void close({bool force = false}) {}
}

/// A [Dio] pointed at TheMealDB's base URL but served by [adapter].
Dio dioWith(FakeHttpClientAdapter adapter) {
  return Dio(BaseOptions(baseUrl: ApiConstants.baseUrl))
    ..httpClientAdapter = adapter;
}
