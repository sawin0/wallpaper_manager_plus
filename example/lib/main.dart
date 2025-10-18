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

  // Pexels video URL for live wallpaper example
  final videoUrl = 'https://www.pexels.com/download/video/7121778/';

  String? selectedVideoPath;
  bool isPickingFile = false;
  bool isDownloadingVideo = false;
  double downloadProgress = 0.0;

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

  Future<void> _downloadAndSetLiveWallpaper() async {
    setState(() {
      isDownloadingVideo = true;
      downloadProgress = 0.0;
    });

    try {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Downloading video from Pexels...')),
      );

      // Download the video file using cache manager
      final fileInfo = await DefaultCacheManager().downloadFile(
        videoUrl,
        authHeaders: null,
      );

      if (!mounted) return;

      if (fileInfo.file.existsSync()) {
        final videoPath = fileInfo.file.path;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video downloaded! Opening wallpaper picker...')),
        );

        // Set the downloaded video as live wallpaper
        final result = await wallpaperManagerPlus.setLiveWallpaper(videoPath);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result ?? 'Live wallpaper picker opened')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to download video')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
      debugPrint('Error downloading video: $e');
    } finally {
      if (mounted) {
        setState(() {
          isDownloadingVideo = false;
          downloadProgress = 0.0;
        });
      }
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

            // Example: Download video from internet
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.blue.shade900,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.cloud_download, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Download from Internet',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Example: Pexels Video',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      if (isDownloadingVideo)
                        Column(
                          children: [
                            const LinearProgressIndicator(),
                            const SizedBox(height: 8),
                            const Text('Downloading video...', style: TextStyle(fontSize: 12)),
                          ],
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _downloadAndSetLiveWallpaper,
                            icon: const Icon(Icons.download),
                            label: const Text('Download & Set Pexels Video'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(12),
                              backgroundColor: Colors.blue,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('OR', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
            ),

            if (selectedVideoPath != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                      label: Text(isPickingFile ? 'Picking...' : 'Select Video File from Device'),
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
                      Text(
                        'Option 1: Download from Internet',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text('• Tap "Download & Set Pexels Video" button'),
                      Text('• Wait for the download to complete'),
                      Text('• The wallpaper picker will open automatically'),
                      SizedBox(height: 8),
                      Text(
                        'Option 2: Use Local Video File',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text('• Tap "Select Video File from Device"'),
                      Text('• Choose an MP4 video from your device'),
                      Text('• Tap "Set as Live Wallpaper" button'),
                      SizedBox(height: 8),
                      Text(
                        'Final Steps (Both Options):',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text('• In the system picker, select "Live Wallpaper Service"'),
                      Text('• Tap "Set wallpaper" to confirm'),
                      Text('• Return to the app to see success notification'),
                      SizedBox(height: 8),
                      Text(
                        'Note: User interaction is required due to Android security policies. The wallpaper will loop continuously and play without sound.',
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
