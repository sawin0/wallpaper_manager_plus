package com.example.wallpaper_manager_plus

import android.app.WallpaperManager
import android.content.Context
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.IOException

/** WallpaperManagerPlusPlugin */
class WallpaperManagerPlus: FlutterPlugin, MethodCallHandler {
  private lateinit var channel: MethodChannel
  private lateinit var context: Context

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "wallpaper_manager_plus")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "setWallpaper" -> setWallpaper(call, result)
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

    try {
      val stream = data.inputStream()
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
        wm.setStream(stream, null, false, location)
      } else {
        wm.setStream(stream)
      }
      result.success("Wallpaper set successfully")
    } catch (e: IOException) {
      e.printStackTrace()
      result.error("IOException", "Failed to set wallpaper: ${e.localizedMessage}", null)
    } catch (e: Exception) {
      e.printStackTrace()
      result.error("Exception", "Unexpected error: ${e.localizedMessage}", null)
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}