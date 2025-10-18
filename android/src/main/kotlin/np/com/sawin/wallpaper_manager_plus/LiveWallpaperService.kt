package np.com.sawin.wallpaper_manager_plus

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.media.MediaPlayer
import android.service.wallpaper.WallpaperService
import android.util.Log
import android.view.SurfaceHolder
import java.io.File

/**
 * Live Wallpaper Service for video/animated wallpapers.
 * Supports MP4 video files and handles lifecycle, visibility, and surface changes.
 */
class LiveWallpaperService : WallpaperService() {

    companion object {
        private const val TAG = "LiveWallpaperService"
        private const val PREFS_NAME = "wallpaper_manager_plus_prefs"
        private const val KEY_VIDEO_PATH = "live_wallpaper_video_path"
    }

    override fun onCreateEngine(): Engine {
        Log.d(TAG, "onCreateEngine called")
        return VideoWallpaperEngine()
    }

    inner class VideoWallpaperEngine : Engine() {
        private var mediaPlayer: MediaPlayer? = null
        private var videoPath: String? = null
        private var isVisible = false
        private var isPrepared = false
        private val paint = Paint().apply {
            color = Color.WHITE
            textSize = 40f
            isAntiAlias = true
        }

        override fun onCreate(surfaceHolder: SurfaceHolder?) {
            super.onCreate(surfaceHolder)
            Log.d(TAG, "Engine onCreate")

            // Load video path from shared preferences
            try {
                val prefs = applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                videoPath = prefs.getString(KEY_VIDEO_PATH, null)

                Log.d(TAG, "Loaded video path: $videoPath")

                if (videoPath != null) {
                    val file = File(videoPath!!)
                    Log.d(TAG, "Video file exists: ${file.exists()}, readable: ${file.canRead()}, size: ${file.length()}")
                } else {
                    Log.w(TAG, "No video path found in SharedPreferences")
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error loading video path", e)
            }
        }

        override fun onSurfaceCreated(holder: SurfaceHolder?) {
            super.onSurfaceCreated(holder)
            Log.d(TAG, "Surface created, holder: $holder")

            // Initialize media player when surface is ready
            if (videoPath != null && File(videoPath!!).exists()) {
                Log.d(TAG, "Initializing MediaPlayer with video: $videoPath")
                initializeMediaPlayer(holder)
            } else {
                Log.w(TAG, "No valid video path found, drawing placeholder")
                drawPlaceholder(holder)
            }
        }

        override fun onSurfaceChanged(holder: SurfaceHolder?, format: Int, width: Int, height: Int) {
            super.onSurfaceChanged(holder, format, width, height)
            Log.d(TAG, "Surface changed: ${width}x${height}, format: $format")

            // Don't restart on surface change if already preparing/prepared
            // Just log the change
        }

        override fun onSurfaceDestroyed(holder: SurfaceHolder?) {
            super.onSurfaceDestroyed(holder)
            Log.d(TAG, "Surface destroyed")
            releaseMediaPlayer()
        }

        override fun onVisibilityChanged(visible: Boolean) {
            super.onVisibilityChanged(visible)
            Log.d(TAG, "Visibility changed: $visible")
            isVisible = visible

            if (visible) {
                // Resume video playback only if prepared
                mediaPlayer?.let {
                    if (isPrepared && !it.isPlaying) {
                        try {
                            Log.d(TAG, "Starting video playback")
                            it.start()
                        } catch (e: Exception) {
                            Log.e(TAG, "Error starting playback", e)
                        }
                    }
                }
            } else {
                // Pause video to save resources
                mediaPlayer?.let {
                    if (it.isPlaying) {
                        try {
                            Log.d(TAG, "Pausing video playback")
                            it.pause()
                        } catch (e: Exception) {
                            Log.e(TAG, "Error pausing playback", e)
                        }
                    }
                }
            }
        }

        override fun onDestroy() {
            super.onDestroy()
            Log.d(TAG, "Engine destroyed")
            releaseMediaPlayer()
        }

        private fun initializeMediaPlayer(holder: SurfaceHolder?) {
            try {
                if (videoPath == null || !File(videoPath!!).exists()) {
                    Log.e(TAG, "Video file not found: $videoPath")
                    drawPlaceholder(holder)
                    return
                }

                releaseMediaPlayer() // Release any existing player
                isPrepared = false

                Log.d(TAG, "Creating MediaPlayer for: $videoPath")
                mediaPlayer = MediaPlayer().apply {
                    setDataSource(videoPath)
                    setSurface(holder?.surface)
                    isLooping = true // Loop the video continuously
                    setVolume(0f, 0f) // Mute audio for wallpaper

                    setOnPreparedListener { mp ->
                        Log.d(TAG, "MediaPlayer prepared successfully")
                        isPrepared = true

                        // Scale video to fit screen while maintaining aspect ratio
                        val videoWidth = mp.videoWidth
                        val videoHeight = mp.videoHeight
                        val surfaceWidth = holder?.surfaceFrame?.width() ?: videoWidth
                        val surfaceHeight = holder?.surfaceFrame?.height() ?: videoHeight

                        Log.d(TAG, "Video: ${videoWidth}x${videoHeight}, Surface: ${surfaceWidth}x${surfaceHeight}")

                        // Only start if visible
                        if (isVisible) {
                            try {
                                Log.d(TAG, "Starting video playback (visible)")
                                mp.start()
                            } catch (e: Exception) {
                                Log.e(TAG, "Error starting playback after prepare", e)
                            }
                        } else {
                            Log.d(TAG, "Not starting video (not visible)")
                        }
                    }

                    setOnErrorListener { mp, what, extra ->
                        Log.e(TAG, "MediaPlayer error: what=$what, extra=$extra")
                        isPrepared = false
                        releaseMediaPlayer()
                        drawPlaceholder(holder)
                        true
                    }

                    setOnInfoListener { mp, what, extra ->
                        Log.d(TAG, "MediaPlayer info: what=$what, extra=$extra")
                        false
                    }

                    setOnCompletionListener { mp ->
                        Log.d(TAG, "Video completed (should loop)")
                    }

                    Log.d(TAG, "Preparing MediaPlayer asynchronously...")
                    prepareAsync() // Prepare asynchronously to avoid blocking
                }

            } catch (e: Exception) {
                Log.e(TAG, "Failed to initialize MediaPlayer", e)
                isPrepared = false
                releaseMediaPlayer()
                drawPlaceholder(holder)
            }
        }

        private fun releaseMediaPlayer() {
            mediaPlayer?.apply {
                try {
                    if (isPlaying) {
                        Log.d(TAG, "Stopping MediaPlayer")
                        stop()
                    }
                    Log.d(TAG, "Releasing MediaPlayer")
                    release()
                } catch (e: Exception) {
                    Log.e(TAG, "Error releasing MediaPlayer", e)
                }
            }
            mediaPlayer = null
            isPrepared = false
        }

        private fun drawPlaceholder(holder: SurfaceHolder?) {
            // Draw a simple placeholder when no video is available
            try {
                val canvas: Canvas? = holder?.lockCanvas()
                canvas?.let {
                    it.drawColor(Color.BLACK)

                    val text = if (videoPath == null) {
                        "Live Wallpaper\nNo video selected"
                    } else {
                        "Live Wallpaper\nVideo error"
                    }

                    val lines = text.split("\n")
                    var y = it.height / 2f - (lines.size * 50f / 2f)

                    lines.forEach { line ->
                        val textWidth = paint.measureText(line)
                        val x = (it.width - textWidth) / 2f
                        it.drawText(line, x, y, paint)
                        y += 60f
                    }

                    holder.unlockCanvasAndPost(it)
                    Log.d(TAG, "Placeholder drawn")
                }
            } catch (e: Exception) {
                Log.e(TAG, "Failed to draw placeholder", e)
            }
        }
    }
}
