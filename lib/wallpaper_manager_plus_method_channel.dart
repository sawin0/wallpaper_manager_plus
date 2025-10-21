import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'wallpaper_manager_plus_platform_interface.dart';

class MethodChannelWallpaperManagerPlus extends WallpaperManagerPlusPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('wallpaper_manager_plus');

  @override
  Future<String?> setWallpaper(File imageFile, int location) async {
    try {
      // Convert image file to byte data
      Uint8List imageByteData = await _readFileByte(imageFile.path);

      // Send byte data and location to the platform channel
      final String? result = await methodChannel.invokeMethod<String>(
        'setWallpaper',
        {
          'data': imageByteData,
          'location': location,
        },
      );

      // Return the result from the platform channel
      return result;
    } on PlatformException catch (e) {
      throw Exception('Failed to set wallpaper: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<String?> setLiveWallpaper(String videoPath) async {
    try {
      final String? result = await methodChannel.invokeMethod<String>(
        'setLiveWallpaper',
        {'videoPath': videoPath},
      );
      return result;
    } on PlatformException catch (e) {
      throw Exception('Failed to set live wallpaper: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Reads the file at [filePath] and returns its byte data.
  ///
  /// Throws an [Exception] if the file cannot be read.
  Future<Uint8List> _readFileByte(String filePath) async {
    File imageFile = File(filePath);
    try {
      Uint8List bytes = await imageFile.readAsBytes();
      return bytes;
    } catch (e) {
      throw Exception('Failed to read image file: $e');
    }
  }
}
