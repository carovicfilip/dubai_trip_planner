import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  // A wrong path only shows up at run time, as a broken image.
  test('every asset path written in lib/ points to a file that exists', () {
    final assetPath = RegExp(r'''['"](assets/[^'"$]+)['"]''');
    final missing = <String>[];
    var checked = 0;
    for (final file in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      for (final match in assetPath.allMatches(file.readAsStringSync())) {
        checked++;
        final path = match.group(1)!;
        if (!File(path).existsSync()) missing.add('${file.path}: $path');
      }
    }
    expect(checked, greaterThan(40), reason: 'the pattern should find the place images, icons and splash');
    expect(missing, isEmpty);
  });
}
