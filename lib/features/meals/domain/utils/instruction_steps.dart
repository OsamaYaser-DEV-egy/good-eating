/// Matches a heading line on its own: "STEP 1", "Step 2:", "step 3.".
final RegExp _stepLabel = RegExp(
  r'^step\s*\d+\s*[:.\-]?$',
  caseSensitive: false,
);

/// Matches numbering at the start of a line: "1. ", "2) ", "Step 3: ".
///
/// The punctuation and the trailing space are both required, so a step that
/// merely starts with a quantity ("2 cups of flour", "1-2 minutes", "12.5 g")
/// is left alone.
final RegExp _leadingNumbering = RegExp(
  r'^\s*(?:step\s*)?\d+\s*[.):\-]\s+',
  caseSensitive: false,
);

/// Splits a recipe's free-text instructions into readable steps.
///
/// TheMealDB separates paragraphs with `\r\n`, and some recipes add their own
/// "STEP 1" headings or "1." numbering. Both are removed because the UI
/// numbers the steps itself.
List<String> splitInstructionSteps(String instructions) {
  final steps = <String>[];
  for (final rawLine in instructions.split(RegExp(r'[\r\n]+'))) {
    final line = rawLine.replaceFirst(_leadingNumbering, '').trim();
    if (line.isEmpty || _stepLabel.hasMatch(line)) continue;
    steps.add(line);
  }

  if (steps.isEmpty && instructions.trim().isNotEmpty) {
    return [instructions.trim()];
  }
  return steps;
}
