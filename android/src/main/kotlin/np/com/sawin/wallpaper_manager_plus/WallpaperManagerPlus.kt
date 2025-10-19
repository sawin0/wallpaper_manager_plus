package np.com.sawin.wallpaper_manager_plus

import android.app.WallpaperManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.widget.Toast
import androidx.annotation.NonNull
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.LifecycleOwner
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.*
import java.io.File
import java.io.IOException
import android.app.Activity

/** WallpaperManagerPlusPlugin */
class WallpaperManagerPlus : FlutterPlugin, MethodCallHandler, ActivityAware {
  private lateinit var channel: MethodChannel
  private lateinit var context: Context
  private var activity: Activity? = null
  private var isSettingWallpaper = false
  private var lifecycleObserver: LifecycleEventObserver? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "wallpaper_manager_plus")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "setWallpaper" -> setWallpaper(call, result)
      "setLiveWallpaper" -> setLiveWallpaper(call, result)
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
    val currentVideoPath = call.argument<String>("videoPath")
    if (currentVideoPath == null) {
      result.error("INVALID_ARGUMENT", "Video path is missing", null)
      return
    }

    // Validate video file exists
    val videoFile = File(currentVideoPath)
    if (!videoFile.exists()) {
      result.error("FILE_NOT_FOUND", "Video file does not exist: $currentVideoPath", null)
      return
    }

    // Pass the video path to the wallpaper service
    LiveWallpaperService.videoPath = currentVideoPath
    isSettingWallpaper = true

    CoroutineScope(Dispatchers.Main).launch {
      try {
        val intent = Intent(WallpaperManager.ACTION_CHANGE_LIVE_WALLPAPER)
        intent.putExtra(
          WallpaperManager.EXTRA_LIVE_WALLPAPER_COMPONENT,
          ComponentName(context, LiveWallpaperService::class.java)
        )
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)

        if (activity != null) {
          activity?.startActivity(intent)
        } else {
          context.startActivity(intent)
        }

        result.success("Live wallpaper picker opened")
      } catch (e: Exception) {
        // Fallback for devices that don't support ACTION_CHANGE_LIVE_WALLPAPER
        try {
          val intent = Intent(WallpaperManager.ACTION_LIVE_WALLPAPER_CHOOSER)
          intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)

          if (activity != null) {
            activity?.startActivity(intent)
          } else {
            context.startActivity(intent)
          }

          result.success("Live wallpaper chooser opened")
        } catch (fallbackException: Exception) {
          isSettingWallpaper = false
          result.error("ERROR", "Failed to open wallpaper chooser: ${fallbackException.message}", null)
        }
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    setupLifecycleObserver(binding)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    removeLifecycleObserver()
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
    setupLifecycleObserver(binding)
  }

  override fun onDetachedFromActivity() {
    removeLifecycleObserver()
    activity = null
  }

  private fun setupLifecycleObserver(binding: ActivityPluginBinding) {
    val activity = binding.activity
    if (activity is LifecycleOwner) {
      lifecycleObserver = LifecycleEventObserver { _, event ->
        if (event == Lifecycle.Event.ON_RESUME) {
          onActivityResumed()
        }
      }
      activity.lifecycle.addObserver(lifecycleObserver!!)
    }
  }

  private fun removeLifecycleObserver() {
    val currentActivity = activity
    if (currentActivity is LifecycleOwner && lifecycleObserver != null) {
      currentActivity.lifecycle.removeObserver(lifecycleObserver!!)
      lifecycleObserver = null
    }
  }

  private fun onActivityResumed() {
    // Check if we were setting wallpaper and now user is back
    if (isSettingWallpaper) {
      isSettingWallpaper = false
      // Check if our wallpaper service is currently set
      val wallpaperManager = WallpaperManager.getInstance(context)
      try {
        val info = wallpaperManager.wallpaperInfo
        if (info != null && info.packageName == context.packageName) {
          activity?.runOnUiThread {
            Toast.makeText(
              context,
              "Live wallpaper set successfully!",
              Toast.LENGTH_LONG
            ).show()
          }
        }
      } catch (e: Exception) {
        // Silently handle any exceptions when checking wallpaper info
        e.printStackTrace()
      }
    }
  }
}
