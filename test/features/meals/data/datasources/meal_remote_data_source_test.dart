import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/core/network/api_client.dart';
import 'package:good_eating/features/meals/data/datasources/meal_remote_data_source.dart';

import '../../../../helpers/fake_http_client_adapter.dart';
import '../../../../helpers/fixture_reader.dart';

(MealRemoteDataSourceImpl, FakeHttpClientAdapter) _sourceReplying(
  String fixture,
) {
  final adapter = FakeHttpClientAdapter.ok(readFixtureText(fixture));
  return (MealRemoteDataSourceImpl(ApiClient(dioWith(adapter))), adapter);
}

void main() {
  test('getCategories requests categories.php and parses the list', () async {
    final (source, adapter) = _sourceReplying('categories.json');

    final categories = await source.getCategories();

    expect(adapter.requests.single.uri.path, endsWith('/categories.php'));
    expect(categories, hasLength(14));
  });

  test('getMealsByCategory sends c=<category> to filter.php', () async {
    final (source, adapter) = _sourceReplying('filter_seafood.json');

    final meals = await source.getMealsByCategory('Seafood');

    final uri = adapter.requests.single.uri;
    expect(uri.path, endsWith('/filter.php'));
    expect(uri.queryParameters, {'c': 'Seafood'});
    expect(meals, hasLength(84));
  });

  test('getMealDetails sends i=<id> to lookup.php', () async {
    final (source, adapter) = _sourceReplying('lookup_52772.json');

    final meal = await source.getMealDetails('52772');

    final uri = adapter.requests.single.uri;
    expect(uri.path, endsWith('/lookup.php'));
    expect(uri.queryParameters, {'i': '52772'});
    expect(meal?.name, 'Teriyaki Chicken Casserole');
  });

  test(
    'getMealDetails returns null when the API replies meals: null',
    () async {
      final (source, _) = _sourceReplying('lookup_unknown.json');
      expect(await source.getMealDetails('0'), isNull);
    },
  );

  test('searchMeals sends s=<query> to search.php', () async {
    final (source, adapter) = _sourceReplying('search_arrabiata.json');

    final meals = await source.searchMeals('Arrabiata');

    final uri = adapter.requests.single.uri;
    expect(uri.path, endsWith('/search.php'));
    expect(uri.queryParameters, {'s': 'Arrabiata'});
    expect(meals.single.name, 'Spicy Arrabiata Penne');
  });

  test(
    'searchMeals returns an empty list, not an error, for meals: null',
    () async {
      final (source, _) = _sourceReplying('search_no_results.json');
      expect(await source.searchMeals('zzzzqqq'), isEmpty);
    },
  );

  test('search text with spaces and symbols is sent intact', () async {
    final (source, adapter) = _sourceReplying('search_no_results.json');

    await source.searchMeals('mac & cheese');

    expect(adapter.requests.single.uri.queryParameters, {'s': 'mac & cheese'});
  });
}
