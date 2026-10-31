import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final out = Platform.environment['E2E_OUT'] ?? 'e2e_out';
  await Directory(out).create(recursive: true);
  await integrationDriver(
    writeResponseOnFailure: true,
    onScreenshot: (name, bytes, [args]) async {
      final file = File('$out/$name.png');
      await file.create(recursive: true);
      await file.writeAsBytes(bytes);
      return true;
    },
    responseDataCallback: (data) async {
      await File('$out/report.json').writeAsString(const JsonEncoder.withIndent('  ').convert(data));
    },
  );
}
