package com.lorn.wallpaper

import android.content.Context
import android.media.MediaPlayer
import android.service.wallpaper.WallpaperService
import android.util.Log
import android.view.SurfaceHolder
import java.io.File

class VideoLiveWallpaperService : WallpaperService() {

    companion object {
        private const val TAG = "VideoLiveWallpaper"
        private const val VIDEO_PREFS = "video_wallpaper_prefs"
        private const val KEY_VIDEO_PATH = "video_path"
        private const val KEY_VERSION = "video_version"

        fun setVideoPath(context: Context, path: String) {
            val prefs = context.getSharedPreferences(VIDEO_PREFS, Context.MODE_PRIVATE)
            val currentVersion = prefs.getLong(KEY_VERSION, 0)
            prefs.edit()
                .putString(KEY_VIDEO_PATH, path)
                .putLong(KEY_VERSION, currentVersion + 1)
                .apply()
        }

        fun getVideoPath(context: Context): String? {
            return context.getSharedPreferences(VIDEO_PREFS, Context.MODE_PRIVATE)
                .getString(KEY_VIDEO_PATH, null)
        }

        fun getVersion(context: Context): Long {
            return context.getSharedPreferences(VIDEO_PREFS, Context.MODE_PRIVATE)
                .getLong(KEY_VERSION, 0)
        }
    }

    override fun onCreateEngine(): Engine {
        return VideoEngine()
    }

    inner class VideoEngine : Engine() {
        private var mediaPlayer: MediaPlayer? = null
        private var surfaceReady = false
        private var isPrepared = false
        private var currentVersion: Long = -1

        override fun onSurfaceCreated(holder: SurfaceHolder) {
            super.onSurfaceCreated(holder)
            surfaceReady = true
            Log.d(TAG, "Surface created")
        }

        override fun onSurfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
            super.onSurfaceChanged(holder, format, width, height)
            Log.d(TAG, "Surface changed: ${width}x${height}")
            // Initial setup — prepare the player once
            val videoPath = getVideoPath(this@VideoLiveWallpaperService)
            val version = getVersion(this@VideoLiveWallpaperService)
            if (videoPath != null && (mediaPlayer == null || version != currentVersion)) {
                preparePlayer(videoPath, version)
            }
        }

        override fun onVisibilityChanged(visible: Boolean) {
            Log.d(TAG, "Visibility changed: $visible")
            if (visible) {
                val videoPath = getVideoPath(this@VideoLiveWallpaperService)
                val version = getVersion(this@VideoLiveWallpaperService)
                // Check if a new wallpaper was set (version bumped)
                if (videoPath != null && version != currentVersion) {
                    preparePlayer(videoPath, version)
                    return
                }
                // Player is ready — just seek to start and play instantly
                try {
                    mediaPlayer?.let { mp ->
                        if (isPrepared) {
                            mp.seekTo(0)
                            mp.start()
                            Log.d(TAG, "Instant resume from start")
                            return
                        }
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Error resuming", e)
                }
                // Fallback: recreate player
                if (videoPath != null && surfaceReady) {
                    preparePlayer(videoPath, version)
                }
            } else {
                // Screen off — just pause, keep the player alive for instant resume
                try {
                    mediaPlayer?.let { mp ->
                        if (mp.isPlaying) mp.pause()
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Error pausing", e)
                }
            }
        }

        override fun onSurfaceDestroyed(holder: SurfaceHolder) {
            Log.d(TAG, "Surface destroyed")
            surfaceReady = false
            releasePlayer()
            super.onSurfaceDestroyed(holder)
        }

        override fun onDestroy() {
            Log.d(TAG, "Engine destroyed")
            surfaceReady = false
            releasePlayer()
            super.onDestroy()
        }

        private fun preparePlayer(videoPath: String, version: Long) {
            releasePlayer()

            val videoFile = File(videoPath)
            if (!videoFile.exists()) {
                Log.e(TAG, "Video file not found: $videoPath")
                return
            }
            if (!surfaceReady) {
                Log.w(TAG, "Surface not ready")
                return
            }

            try {
                val holder = surfaceHolder ?: return
                val surface = holder.surface ?: return
                if (!surface.isValid) return

                mediaPlayer = MediaPlayer().apply {
                    setSurface(surface)
                    setDataSource(videoPath)
                    isLooping = true
                    setVolume(0f, 0f)
                    // Use synchronous prepare — fast for local files
                    prepare()
                    isPrepared = true
                    currentVersion = version
                    start()
                    Log.d(TAG, "Player prepared & started (v$version): $videoPath")
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error preparing player", e)
                isPrepared = false
                releasePlayer()
            }
        }

        private fun releasePlayer() {
            try {
                mediaPlayer?.let { mp ->
                    try { if (mp.isPlaying) mp.stop() } catch (_: Exception) {}
                    try { mp.reset() } catch (_: Exception) {}
                    try { mp.release() } catch (_: Exception) {}
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error releasing", e)
            }
            mediaPlayer = null
            isPrepared = false
            // Don't reset currentVersion here — we need it to compare against new versions
        }
    }
}
