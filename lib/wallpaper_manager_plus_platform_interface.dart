import 'dart:io';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'wallpaper_manager_plus_method_channel.dart';

abstract class WallpaperManagerPlusPlatform extends PlatformInterface {
  /// Constructs a WallpaperManagerPlusPlatform.
  WallpaperManagerPlusPlatform() : super(token: _token);

  static final Object _token = Object();

  static WallpaperManagerPlusPlatform _instance =
      MethodChannelWallpaperManagerPlus();

  /// The default instance of [WallpaperManagerPlusPlatform] to use.
  ///
  /// Defaults to [MethodChannelWallpaperManagerPlus].
  static WallpaperManagerPlusPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [WallpaperManagerPlusPlatform] when
  /// they register themselves.
  static set instance(WallpaperManagerPlusPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Sets the wallpaper for the specified location.
  ///
  /// [imageFile] is the file containing the image to be set as wallpaper.
  /// [location] is the screen location where the wallpaper should be set.
  /// It can be [homeScreen], [lockScreen], or [bothScreens].
  ///
  /// Throws an [UnimplementedError] if the method is not implemented by the platform.
  Future<String?> setWallpaper(File imageFile, int location) {
    throw UnimplementedError('setWallpaper() has not been implemented.');
  }

  /// Sets a live wallpaper from a video file.
  ///
  /// [videoPath] is the path to the video file.
  /// Opens the system live wallpaper picker for user to apply.
  Future<String?> setLiveWallpaper(String videoPath) {
    throw UnimplementedError('setLiveWallpaper() has not been implemented.');
  }
}
