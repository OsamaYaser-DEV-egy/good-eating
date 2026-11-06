import 'package:good_eating/core/error/exceptions.dart';

/// Reads [key] as a trimmed string, or null when it is missing, null, or blank.
///
/// TheMealDB uses `null`, `""` and `" "` interchangeably for "no value", and
/// can send ids as numbers, so everything is normalised through here.
String? readString(Map<String, dynamic> json, String key) {
  final Object? value = json[key];
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

/// Decodes the list stored under [key] with [fromJson].
///
/// Returns an empty list when the value is not a list. TheMealDB answers "no
/// results" with `{"meals": null}`, so that case must never throw.
///
/// Entries that are not objects, or that [fromJson] rejects with a
/// [ParsingException] because a required field is missing, are skipped: one
/// malformed entry should not hide the rest of the list.
List<T> parseJsonList<T>(
  Map<String, dynamic> json,
  String key,
  T Function(Map<String, dynamic> json) fromJson,
) {
  final Object? raw = json[key];
  if (raw is! List<Object?>) return const [];

  final items = <T>[];
  for (final entry in raw) {
    if (entry is! Map<String, dynamic>) continue;
    try {
      items.add(fromJson(entry));
    } on ParsingException {
      continue;
    }
  }
  return items;
}
