// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://docs.flutter.dev/cookbook/testing/integration/introduction

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('getPlatformVersion test', (WidgetTester tester) async {
    final WallpaperManagerPlus plugin = WallpaperManagerPlus();

    // Create a temporary placeholder file and write a single byte.
    final tmpDir = await Directory.systemTemp.createTemp('wallpaper_test');
    final file = File('${tmpDir.path}/wallpaper.gif');
    await file.writeAsBytes([0]);

    // Pass the File to setWallpaper (location remains an int).
    await plugin.setWallpaper(file, 0);

    // Clean up the temporary directory.
    await tmpDir.delete(recursive: true);
  });
}
