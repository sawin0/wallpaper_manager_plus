import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart';
import 'package:file_picker/file_picker.dart';

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
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WallpaperManagerPlus wallpaperManagerPlus = WallpaperManagerPlus();
  final imageurl =
      'https://unsplash.com/photos/AnBzL_yOWBc/download?force=true&w=2400';

  String? selectedVideoPath;
  bool isPickingFile = false;

  Future<void> _setWallpaper(int location) async {
    final file = await DefaultCacheManager().getSingleFile(imageurl);
    try {
      final result = await wallpaperManagerPlus.setWallpaper(file, location);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result ?? 'Wallpaper set successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
      debugPrint(e.toString());
    }
  }

  Future<void> _pickVideoFile() async {
    setState(() {
      isPickingFile = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          selectedVideoPath = result.files.single.path!;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Video selected: ${result.files.single.name}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    } finally {
      setState(() {
        isPickingFile = false;
      });
    }
  }

  Future<void> _setLiveWallpaper() async {
    if (selectedVideoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a video file first')),
      );
      return;
    }

    try {
      final result = await wallpaperManagerPlus.setLiveWallpaper(selectedVideoPath!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result ?? 'Live wallpaper picker opened')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
      debugPrint(e.toString());
    }
  }

  Future<void> _openLiveWallpaperPicker() async {
    try {
      final result = await wallpaperManagerPlus.openLiveWallpaperPicker();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result ?? 'Picker opened')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallpaper Manager Plus Example'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Static Wallpaper Section
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Static Image Wallpaper',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 300,
              width: MediaQuery.of(context).size.width,
              child: CachedNetworkImage(
                imageUrl: imageurl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.error_outline_rounded, color: Colors.red),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _setWallpaper(WallpaperManagerPlus.homeScreen),
                      child: const Text('Home Screen'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _setWallpaper(WallpaperManagerPlus.lockScreen),
                      child: const Text('Lock Screen'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _setWallpaper(WallpaperManagerPlus.bothScreens),
                      child: const Text('Both Screens'),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 32, thickness: 2),

            // Live Wallpaper Section
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Live Wallpaper (Video)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            if (selectedVideoPath != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.video_file, size: 40),
                    title: Text(
                      selectedVideoPath!.split('/').last,
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: const Text('Selected video file'),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          selectedVideoPath = null;
                        });
                      },
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isPickingFile ? null : _pickVideoFile,
                      icon: isPickingFile
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Icon(Icons.video_library),
                      label: Text(isPickingFile ? 'Picking...' : 'Select Video File'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: selectedVideoPath != null ? _setLiveWallpaper : null,
                      icon: const Icon(Icons.wallpaper),
                      label: const Text('Set as Live Wallpaper'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _openLiveWallpaperPicker,
                      icon: const Icon(Icons.settings),
                      label: const Text('Open Live Wallpaper Picker'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ℹ️ Live Wallpaper Instructions:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text('1. Select an MP4 video file from your device'),
                      Text('2. Tap "Set as Live Wallpaper"'),
                      Text('3. In the system picker, select "Video Live Wallpaper"'),
                      Text('4. Tap "Set wallpaper" to confirm'),
                      SizedBox(height: 8),
                      Text(
                        'Note: User interaction is required due to Android security policies.',
                        style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
