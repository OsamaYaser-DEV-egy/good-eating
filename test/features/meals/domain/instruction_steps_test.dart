import 'package:flutter_test/flutter_test.dart';

import 'package:good_eating/features/meals/domain/utils/instruction_steps.dart';

void main() {
  group('splitInstructionSteps', () {
    test('splits on Windows and Unix line breaks', () {
      expect(splitInstructionSteps('Mix.\r\nBake.\nServe.'), [
        'Mix.',
        'Bake.',
        'Serve.',
      ]);
    });

    test('drops blank lines between paragraphs', () {
      expect(splitInstructionSteps('One.\r\n\r\n\r\nTwo.'), ['One.', 'Two.']);
    });

    test('removes STEP headings that sit on their own line', () {
      expect(
        splitInstructionSteps('STEP 1\r\nChop onions.\r\nSTEP 2\r\nFry them.'),
        ['Chop onions.', 'Fry them.'],
      );
    });

    test('removes headings written with a colon or full stop', () {
      expect(splitInstructionSteps('Step 1:\nChop.\nstep 2.\nFry.'), [
        'Chop.',
        'Fry.',
      ]);
    });

    test('strips numbering from the start of a step', () {
      expect(splitInstructionSteps('1. Chop.\n2) Fry.\nStep 3: Serve.'), [
        'Chop.',
        'Fry.',
        'Serve.',
      ]);
    });

    test('leaves a step that merely starts with a quantity alone', () {
      expect(
        splitInstructionSteps(
          '2 cups of flour go in.\n1-2 minutes later.\n12.5 g salt.',
        ),
        ['2 cups of flour go in.', '1-2 minutes later.', '12.5 g salt.'],
      );
    });

    test('returns a single step for text without line breaks', () {
      expect(splitInstructionSteps('Just bake it.'), ['Just bake it.']);
    });

    test('returns nothing for empty or whitespace-only text', () {
      expect(splitInstructionSteps(''), isEmpty);
      expect(splitInstructionSteps('  \r\n  '), isEmpty);
    });

    test('keeps the text when it is only a heading', () {
      expect(splitInstructionSteps('STEP 1'), ['STEP 1']);
    });
  });
}
