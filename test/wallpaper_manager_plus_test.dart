import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:wallpaper_manager_plus/wallpaper_manager_plus_method_channel.dart';
import 'package:wallpaper_manager_plus/wallpaper_manager_plus_platform_interface.dart';

class MockWallpaperManagerPlusPlatform
    with MockPlatformInterfaceMixin
    implements WallpaperManagerPlusPlatform {
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<String?> setWallpaper(imagefile, location) async {
    return null;
  }

  @override
  Future<String?> setLiveWallpaper(String videoPath) {
    // TODO: implement setLiveWallpaper
    throw UnimplementedError();
  }
}

void main() {
  final WallpaperManagerPlusPlatform initialPlatform =
      WallpaperManagerPlusPlatform.instance;

  test('$MethodChannelWallpaperManagerPlus is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelWallpaperManagerPlus>());
  });
}
