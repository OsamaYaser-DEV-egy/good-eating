import 'package:flutter_test/flutter_test.dart';
import 'package:good_eating/core/error/exceptions.dart';
import 'package:good_eating/features/favorites/data/datasources/favorites_local_data_source.dart';
import 'package:good_eating/features/favorites/data/models/favorite_meal_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

/// A store that accepts reads but refuses every write, like a full disk.
class _RefusingStore extends InMemorySharedPreferencesStore {
  _RefusingStore() : super.empty();

  @override
  Future<bool> setValue(String valueType, String key, Object value) async =>
      false;
}

const _soup = FavoriteMealModel(id: '1', name: 'Soup', thumbUrl: 'soup.jpg');
const _stew = FavoriteMealModel(id: '2', name: 'Stew', thumbUrl: 'stew.jpg');

Future<FavoritesLocalDataSourceImpl> _sourceWith([
  Map<String, Object> initial = const {},
]) async {
  SharedPreferences.setMockInitialValues(initial);
  return FavoritesLocalDataSourceImpl(await SharedPreferences.getInstance());
}

void main() {
  group('reading', () {
    test('returns nothing when nothing has been saved', () async {
      final source = await _sourceWith();
      expect(await source.read(), isEmpty);
    });

    test('returns what was written, in the same order', () async {
      final source = await _sourceWith();
      await source.write([_stew, _soup]);

      final saved = await source.read();

      expect(saved.map((m) => m.id), ['2', '1']);
      expect(saved.first.name, 'Stew');
      expect(saved.first.thumbUrl, 'stew.jpg');
    });

    test('keeps names with quotes, accents and symbols intact', () async {
      const awkward = [
        FavoriteMealModel(id: '1', name: 'Æbleskiver', thumbUrl: ''),
        FavoriteMealModel(id: '2', name: 'Mom\'s "special" stew', thumbUrl: ''),
        FavoriteMealModel(
          id: '3',
          name: 'Mac & cheese / <b>bold</b>',
          thumbUrl: '',
        ),
        FavoriteMealModel(id: '4', name: 'Curry 🍛 line\nbreak', thumbUrl: ''),
      ];
      final source = await _sourceWith();
      await source.write(awkward);

      final saved = await source.read();

      expect(saved.map((m) => m.name), awkward.map((m) => m.name));
    });

    test('survives being read through a brand new instance', () async {
      final first = await _sourceWith();
      await first.write([_soup]);

      // A new data source over the same store is what a relaunch looks like.
      final second = FavoritesLocalDataSourceImpl(
        await SharedPreferences.getInstance(),
      );

      expect((await second.read()).single.id, '1');
    });
  });

  group('writing', () {
    test('replaces the previous list', () async {
      final source = await _sourceWith();
      await source.write([_soup, _stew]);
      await source.write([_stew]);

      expect((await source.read()).map((m) => m.id), ['2']);
    });

    test('an empty list clears everything', () async {
      final source = await _sourceWith();
      await source.write([_soup]);
      await source.write(const []);

      expect(await source.read(), isEmpty);
    });

    test('stores under one stable key', () async {
      final source = await _sourceWith();
      await source.write([_soup]);

      final preferences = await SharedPreferences.getInstance();
      expect(FavoritesLocalDataSourceImpl.storageKey, 'favorite_meals');
      expect(preferences.getString('favorite_meals'), isNotNull);
    });

    test('reports a CacheException when the store refuses the write', () async {
      SharedPreferences.resetStatic();
      SharedPreferencesStorePlatform.instance = _RefusingStore();
      final source = FavoritesLocalDataSourceImpl(
        await SharedPreferences.getInstance(),
      );

      expect(() => source.write([_soup]), throwsA(isA<CacheException>()));
    });
  });

  group('unreadable data', () {
    const key = FavoritesLocalDataSourceImpl.storageKey;

    test('text that is not JSON counts as nothing saved', () async {
      final source = await _sourceWith({key: 'definitely not json'});
      expect(await source.read(), isEmpty);
    });

    test('JSON that is not a list counts as nothing saved', () async {
      final source = await _sourceWith({key: '{"id": "1", "name": "Soup"}'});
      expect(await source.read(), isEmpty);
    });

    test('keeps the good records and drops the broken ones', () async {
      final source = await _sourceWith({
        key:
            '[1, "text", null, {"id": "1"}, {"name": "No id"}, '
            '{"id": "2", "name": "Stew", "thumbUrl": "stew.jpg"}, '
            '{"id": "3", "name": ""}]',
      });

      final saved = await source.read();

      expect(saved.map((m) => m.id), ['2']);
    });

    test('a later save replaces the corrupt value', () async {
      final source = await _sourceWith({key: '}{ corrupt'});
      expect(await source.read(), isEmpty);

      await source.write([_soup]);

      expect((await source.read()).single.id, '1');
    });
  });
}
