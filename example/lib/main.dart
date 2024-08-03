import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart'
    show WallpaperManagerPlus;

void main() {
  runApp(
    MaterialApp(
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
    ),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen>  createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WallpaperManagerPlus wallpaperManagerPlus = WallpaperManagerPlus();
  final imageurl =
      'https://unsplash.com/photos/AnBzL_yOWBc/download?force=true&w=2400';
  // 'https://unsplash.com/photos/1zTg4KT4EtE/download?force=true&w=2400';

  // Image Dimensions are 2400 x 3598

  Future<void> _setwallpaper(location) async {
    final file = await DefaultCacheManager().getSingleFile(imageurl);
    try {
      final result = await wallpaperManagerPlus.setWallpaper(file, location);
      ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
          content: Text(result ?? ''),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error Setting Wallpaper'),
        ),
      );
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallpaper Manager Example'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: CachedNetworkImage(
                imageUrl: imageurl,
                fit: BoxFit.fill,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, uri) => const Center(
                  child: Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    _setwallpaper(WallpaperManagerPlus.homeScreen);
                  },
                  child: const Text('Home Screen'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _setwallpaper(WallpaperManagerPlus.lockScreen);
                  },
                  child: const Text('Lock Screen'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _setwallpaper(WallpaperManagerPlus.bothScreens);
                  },
                  child: const Text('Both Screens'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
