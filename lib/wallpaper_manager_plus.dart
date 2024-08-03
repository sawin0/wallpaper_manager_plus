import 'wallpaper_manager_plus_platform_interface.dart';

class WallpaperManagerPlus {
  static const int homeScreen = 1;
  // To set wallpaper for Home Screen.

  static const int lockScreen = 2;
  // To set wallpaper for Lock Screen.

  static const int bothScreens = 3;
  // To set wallpaper for Both Screens.

  /// Sets the wallpaper for the specified location.
  ///
  /// [imageFile] is the file containing the image to be set as wallpaper.
  /// [location] is the screen location where the wallpaper should be set.
  /// It can be [homeScreen], [lockScreen], or [bothScreens].
  ///
  /// Throws an [ArgumentError] if [location] is invalid.
  Future<String?> setWallpaper(dynamic imageFile, int location) async {
    if (location != homeScreen &&
        location != lockScreen &&
        location != bothScreens) {
      throw ArgumentError('Invalid location: $location');
    }
    try {
      return await WallpaperManagerPlusPlatform.instance
          .setWallpaper(imageFile, location);
    } catch (e) {
      // Handle any errors that occur during the wallpaper setting process.
      rethrow;
    }
  }
}
