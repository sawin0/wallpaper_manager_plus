import 'wallpaper_manager_plus_platform_interface.dart';
import 'dart:io';

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
  Future<String?> setWallpaper(File imageFile, int location) async {
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

  /// Sets a live wallpaper from a video file (MP4, etc.).
  ///
  /// This will save the video path and open the system's live wallpaper picker
  /// where the user must manually select and apply the wallpaper.
  ///
  /// [videoFile] can be a File object or a String path to the video file.
  ///
  /// Returns a success message when the picker is opened.
  /// User interaction is required to complete the wallpaper setup.
  Future<String?> setLiveWallpaper(dynamic videoFile) async {
    try {
      String path;
      if (videoFile is File) {
        path = videoFile.path;
      } else if (videoFile is String) {
        path = videoFile;
      } else {
        throw ArgumentError('videoFile must be a File or String path');
      }

      return await WallpaperManagerPlusPlatform.instance.setLiveWallpaper(path);
    } catch (e) {
      rethrow;
    }
  }
}
