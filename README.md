# 📱 wallpaper\_manager\_plus

**A modern, lightweight Flutter plugin to set wallpapers on Android Home Screen, Lock Screen, or both. Built for performance, reliability, and large image support.**

---

## 🔔 Why Choose `wallpaper_manager_plus`?


✅ **Built using Kotlin coroutines** to handle wallpaper setting in a background thread — effectively **preventing ANR (Application Not Responding)** issues common in older implementations.

✅ Perfect for developers building wallpaper apps, personalization tools, or utilities requiring dynamic background changes.

📣 Have a feature request or bug to report? [Open an issue](https://github.com/your_repo_url/issues) or contribute via pull request!

---

## 🚀 Key Features

* 🏠 Set wallpaper on **Home Screen**, **Lock Screen**, or **Both**
* 🖼️ Seamless support for **large images**
* 💾 Works with **cached network images** and **local files**
* ⚡ Lightweight and **easy to integrate**
* 🔄 Compatible with **Flutter null safety** and **latest Dart versions**

---

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  wallpaper_manager_plus: ^0.0.1
```

Import it in your Dart file:

```dart
import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart';
```

---

## 🛠️ How to Use

### 🔹 Set Wallpaper from Cached Network Image

To set a wallpaper from a remote image URL using caching, integrate the [`flutter_cache_manager`](https://pub.dev/packages/flutter_cache_manager):

#### Step 1: Add dependency

```yaml
dependencies:
  flutter_cache_manager: ^3.4.0
```

#### Step 2: Import packages

```dart
import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart';
```

#### Step 3: Example code

```dart
String imageUrl = 'https://example.com/image.jpg';
File file = await DefaultCacheManager().getSingleFile(imageUrl);

int location = WallpaperManagerPlus.HOME_SCREEN;

await WallpaperManagerPlus().setWallpaper(file.path, location);
```

📌 *Use a `try-catch` block for error handling.*

---

### 🔹 Set Wallpaper from Local File

Use a file from local storage:

```dart
String imagePath = '/storage/emulated/0/Download/image.png';
int location = WallpaperManagerPlus.HOME_SCREEN;

await WallpaperManagerPlus().setWallpaper(imagePath, location);
```

---

## 💡 Full Example

Check out the [example/](example) directory for a complete working example.

---

## 🤝 Contribute to Development

We welcome your contributions! If you want to:

* Add new features
* Fix bugs
* Improve documentation

Fork the repository and submit a pull request. Every contribution helps!
