import 'dart:convert';
import 'dart:io';

/// Raw text of a file in `test/fixtures/`. `flutter test` runs from the
/// project root, so the relative path is stable.
String readFixtureText(String name) =>
    File('test/fixtures/$name').readAsStringSync();

/// A fixture decoded as a JSON object, exactly as `ApiClient` would return it.
Map<String, dynamic> readFixtureJson(String name) =>
    jsonDecode(readFixtureText(name)) as Map<String, dynamic>;
