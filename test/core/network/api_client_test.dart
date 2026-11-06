import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/core/error/exceptions.dart';
import 'package:good_eating/core/network/api_client.dart';

import '../../helpers/fake_http_client_adapter.dart';

ApiClient _client(FakeHttpClientAdapter adapter) => ApiClient(dioWith(adapter));

void main() {
  test('returns a JSON object response as a map', () async {
    final client = _client(FakeHttpClientAdapter.ok('{"meals": null}'));
    expect(await client.get('search.php'), {'meals': null});
  });

  test('decodes a body served with a non-JSON content type', () async {
    final client = _client(
      FakeHttpClientAdapter.ok('{"meals": []}', contentType: 'text/plain'),
    );
    expect(await client.get('search.php'), {'meals': <Object?>[]});
  });

  test('sends the path and query parameters', () async {
    final adapter = FakeHttpClientAdapter.ok('{}');
    await _client(adapter)
        .get('filter.php', queryParameters: {'c': 'Side dish'});

    final uri = adapter.requests.single.uri;
    expect(uri.path, endsWith('/filter.php'));
    expect(uri.queryParameters, {'c': 'Side dish'});
  });

  test('throws ParsingException when the body is not a JSON object', () {
    final client = _client(FakeHttpClientAdapter.ok('[1, 2, 3]'));
    expect(() => client.get('x'), throwsA(isA<ParsingException>()));
  });

  test('throws FormatException for a body that is not JSON at all', () {
    final client = _client(
      FakeHttpClientAdapter.ok('<html>oops</html>', contentType: 'text/html'),
    );
    expect(() => client.get('x'), throwsFormatException);
  });

  test('surfaces an error status as a DioException', () {
    final client = _client(FakeHttpClientAdapter.status(500));
    expect(() => client.get('x'), throwsA(isA<DioException>()));
  });
}
