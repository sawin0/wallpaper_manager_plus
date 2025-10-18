package np.com.sawin.wallpaper_manager_plus

import android.app.WallpaperManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.*
import java.io.File
import java.io.IOException

/** WallpaperManagerPlusPlugin */
class WallpaperManagerPlus : FlutterPlugin, MethodCallHandler {
  private lateinit var channel: MethodChannel
  private lateinit var context: Context

  companion object {
    private const val PREFS_NAME = "wallpaper_manager_plus_prefs"
    private const val KEY_VIDEO_PATH = "live_wallpaper_video_path"
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "wallpaper_manager_plus")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "setWallpaper" -> setWallpaper(call, result)
      "setLiveWallpaper" -> setLiveWallpaper(call, result)
      "openLiveWallpaperPicker" -> openLiveWallpaperPicker(result)
      else -> result.notImplemented()
    }
  }

  private fun setWallpaper(call: MethodCall, result: Result) {
    val wm = WallpaperManager.getInstance(context)
    val data = call.argument<ByteArray>("data")
    val location = call.argument<Int>("location")

    if (data == null || location == null) {
      result.error("INVALID_ARGUMENT", "Data or location argument is missing", null)
      return
    }

    CoroutineScope(Dispatchers.IO).launch {
      try {
        val stream = data.inputStream()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
          wm.setStream(stream, null, false, location)
        } else {
          wm.setStream(stream)
        }

        withContext(Dispatchers.Main) {
          result.success("Wallpaper set successfully")
        }
      } catch (e: IOException) {
        e.printStackTrace()
        withContext(Dispatchers.Main) {
          result.error("IOException", "Failed to set wallpaper: ${e.localizedMessage}", null)
        }
      } catch (e: SecurityException) {
        e.printStackTrace()
        withContext(Dispatchers.Main) {
          result.error("SecurityException", "Permission denied: ${e.localizedMessage}", null)
        }
      } catch (e: Exception) {
        e.printStackTrace()
        withContext(Dispatchers.Main) {
          result.error("Exception", "Unexpected error: ${e.localizedMessage}", null)
        }
      }
    }
  }

  private fun setLiveWallpaper(call: MethodCall, result: Result) {
    val videoPath = call.argument<String>("videoPath")
    android.util.Log.d("WallpaperManagerPlus", "setLiveWallpaper called with path: $videoPath")

    if (videoPath == null) {
      result.error("INVALID_ARGUMENT", "videoPath is missing", null)
      return
    }

    val file = File(videoPath)
    if (!file.exists()) {
      android.util.Log.e("WallpaperManagerPlus", "Video file does not exist: $videoPath")
      result.error("FILE_NOT_FOUND", "Video file does not exist: $videoPath", null)
      return
    }

    android.util.Log.d("WallpaperManagerPlus", "Video file exists: ${file.length()} bytes")

    try {
      // Save video path to shared preferences so the service can access it
      val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
      prefs.edit().putString(KEY_VIDEO_PATH, videoPath).apply()

      // Verify it was saved
      val savedPath = prefs.getString(KEY_VIDEO_PATH, null)
      android.util.Log.d("WallpaperManagerPlus", "Saved and verified path: $savedPath")

      // Open the live wallpaper picker with our service pre-selected
      val intent = Intent(WallpaperManager.ACTION_CHANGE_LIVE_WALLPAPER).apply {
        putExtra(
          WallpaperManager.EXTRA_LIVE_WALLPAPER_COMPONENT,
          ComponentName(context.packageName, "np.com.sawin.wallpaper_manager_plus.LiveWallpaperService")
        )
        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
      }

      android.util.Log.d("WallpaperManagerPlus", "Opening picker with component: ${context.packageName}/np.com.sawin.wallpaper_manager_plus.LiveWallpaperService")
      context.startActivity(intent)
      result.success("Live wallpaper picker opened. Please select the wallpaper to apply.")

    } catch (e: Exception) {
      e.printStackTrace()
      android.util.Log.e("WallpaperManagerPlus", "Error setting live wallpaper", e)
      result.error("Exception", "Failed to set live wallpaper: ${e.localizedMessage}", null)
    }
  }

  private fun openLiveWallpaperPicker(result: Result) {
    try {
      val intent = Intent(WallpaperManager.ACTION_CHANGE_LIVE_WALLPAPER).apply {
        putExtra(
          WallpaperManager.EXTRA_LIVE_WALLPAPER_COMPONENT,
          ComponentName(context.packageName, "np.com.sawin.wallpaper_manager_plus.LiveWallpaperService")
        )
        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
      }

      context.startActivity(intent)
      result.success("Live wallpaper picker opened")

    } catch (e: Exception) {
      e.printStackTrace()
      result.error("Exception", "Failed to open live wallpaper picker: ${e.localizedMessage}", null)
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
