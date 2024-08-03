# Note

This package is heavily inspired by the [wallpaper_manager_flutter](https://pub.dev/packages/wallpaper_manager_flutter) package and has an exact implementation. The original package seems not to be maintained by the maintainer, so this serves as an alternative for those who loved the wallpaper_manager_flutter package.

If you encounter any issues or have suggestions for improvements, feel free to contribute or reach out!



# wallpaper_manager_plus

A Plugin to set Wallpaper of HomeScreen,LockScreen and Both Screen without lag even for large images.


## Installation

In the pubspec.yaml of your flutter project, add the following dependency:

```dart
dependencies:
  wallpaper_manager_plus: ^0.0.1
```
In your dart file add the following import:

```dart
  import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart';
```
# Usage

## Set Wallpaper from cache file

You can use flutter_cache_manager package to access the cached image files,

In the pubspec.yaml of your flutter project, add the following dependency:

```dart
dependencies:
  flutter_cache_manager: ^3.4.0
```

In your dart file add the following import:

```dart
  import 'package:flutter_cache_manager/flutter_cache_manager.dart';
```

Now pass the image url to the cache manager and await cachedimage and then pass the cached image to the plugin.

Use this inside an async function.

```dart
String url = '';  // Image url 

String cachedimage = await DefaultCacheManager().getSingleFile(url);  //image file

int location = WallpaperManagerPlus.HOME_SCREEN;  //Choose screen type

WallpaperManagerPlus().setWallpaper(cachedimage, location);   // Wrap with try catch for error management.
```

Check the Example file for Better Understanding.

## Set wallpaper from system file

Use this inside an async Function,

```dart
imagefile = /0/images/image.png,

location = WallpaperManagerPlus.HOME_SCREEN  //Choose screen type

WallpaperManagerPlus().setWallpaper(imagefile, location);
```
