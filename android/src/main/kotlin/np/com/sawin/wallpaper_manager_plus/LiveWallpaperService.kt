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
        var videoPath: String? = null
    }

    override fun onCreateEngine(): Engine {
        return VideoEngine()
    }

    inner class VideoEngine : Engine() {
        private var mediaPlayer: MediaPlayer? = null

        override fun onCreate(surfaceHolder: SurfaceHolder?) {
            super.onCreate(surfaceHolder)
        }

        override fun onVisibilityChanged(visible: Boolean) {
            if (visible) {
                startPlayback()
            } else {
                stopPlayback()
            }
        }

        override fun onSurfaceCreated(holder: SurfaceHolder) {
            super.onSurfaceCreated(holder)
            startPlayback()
        }

        override fun onSurfaceDestroyed(holder: SurfaceHolder) {
            super.onSurfaceDestroyed(holder)
            stopPlayback()
        }

        override fun onDestroy() {
            super.onDestroy()
            stopPlayback()
        }

        private fun startPlayback() {
            stopPlayback()

            val path = videoPath
            if (path.isNullOrEmpty()) {
                return
            }

            val videoFile = File(path)
            if (!videoFile.exists()) {
                return
            }

            try {
                mediaPlayer = MediaPlayer().apply {
                    setSurface(surfaceHolder.surface)
                    setDataSource(path)
                    isLooping = true
                    setVolume(0f, 0f) // Mute the video
                    prepare()
                    start()
                }
            } catch (e: Exception) {
                e.printStackTrace()
                mediaPlayer?.release()
                mediaPlayer = null
            }
        }

        private fun stopPlayback() {
            mediaPlayer?.apply {
                if (isPlaying) {
                    stop()
                }
                release()
            }
            mediaPlayer = null
        }
    }
}
