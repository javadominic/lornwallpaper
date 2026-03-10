package com.lorn.wallpaper

import android.app.WallpaperManager
import android.content.ComponentName
import android.content.Intent
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.lorn.wallpaper/wallpaper"
    private val TAG = "LornMainActivity"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setLiveWallpaper" -> {
                        val videoPath = call.argument<String>("videoPath")
                        if (videoPath == null) {
                            result.error("INVALID_ARG", "videoPath is required", null)
                            return@setMethodCallHandler
                        }
                        Thread {
                            try {
                                // Delete old file first, then copy new video
                                val destFile = File(filesDir, "live_wallpaper.mp4")
                                if (destFile.exists()) destFile.delete()
                                File(videoPath).copyTo(destFile, overwrite = true)
                                Log.d(TAG, "Video copied: ${destFile.absolutePath} (${destFile.length()} bytes)")

                                // Save path for WallpaperService to pick up
                                VideoLiveWallpaperService.setVideoPath(this, destFile.absolutePath)

                                // Launch the live wallpaper picker pre-populated with our service
                                val component = ComponentName(this, VideoLiveWallpaperService::class.java)
                                runOnUiThread {
                                    try {
                                        val intent = Intent(WallpaperManager.ACTION_CHANGE_LIVE_WALLPAPER).apply {
                                            putExtra(
                                                WallpaperManager.EXTRA_LIVE_WALLPAPER_COMPONENT,
                                                component
                                            )
                                        }
                                        startActivity(intent)
                                        result.success("picker_opened")
                                    } catch (e: Exception) {
                                        Log.e(TAG, "Error opening picker", e)
                                        result.error("ERROR", e.message, null)
                                    }
                                }
                            } catch (e: Exception) {
                                Log.e(TAG, "Error setting wallpaper", e)
                                runOnUiThread {
                                    result.error("ERROR", e.message, null)
                                }
                            }
                        }.start()
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
