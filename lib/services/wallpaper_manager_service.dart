import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// ─── Wallpaper Manager Service ──────────────────────────────────────────────
/// Uses a platform channel to trigger Android's native live wallpaper service.
/// Copies the video asset to a temp file, then sets it as the live wallpaper
/// on Android (applies to both home & lock screens — Android limitation).
/// ─────────────────────────────────────────────────────────────────────────────

enum WallpaperSetState { idle, setting, success, error }

class WallpaperSetResult {
  final WallpaperSetState state;
  final String? message;

  const WallpaperSetResult({
    required this.state,
    this.message,
  });

  const WallpaperSetResult.idle()
      : state = WallpaperSetState.idle,
        message = null;
}

class WallpaperManagerService extends ChangeNotifier {
  static const _channel = MethodChannel('com.lorn.wallpaper/wallpaper');

  WallpaperSetResult _result = const WallpaperSetResult.idle();
  WallpaperSetResult get result => _result;

  /// Set a live video wallpaper from a video asset path.
  Future<bool> setWallpaper({
    required String videoAssetPath,
  }) async {
    _result = const WallpaperSetResult(state: WallpaperSetState.setting);
    notifyListeners();

    try {
      // On web/desktop, just simulate (no native wallpaper API)
      if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
        await Future.delayed(const Duration(seconds: 1));
        _result = const WallpaperSetResult(
          state: WallpaperSetState.success,
          message: 'Wallpaper preview only (not supported on this platform)',
        );
        notifyListeners();
        return true;
      }

      // Copy asset to temp file so native code can access it
      final tempPath = await _copyAssetToTemp(videoAssetPath);

      // Call native side
      await _channel.invokeMethod('setLiveWallpaper', {
        'videoPath': tempPath,
      });

      _result = const WallpaperSetResult(
        state: WallpaperSetState.success,
        message: 'Live wallpaper set!',
      );
      notifyListeners();
      return true;
    } catch (e) {
      _result = WallpaperSetResult(
        state: WallpaperSetState.error,
        message: 'Failed to set wallpaper: ${e.toString()}',
      );
      notifyListeners();
      return false;
    }
  }

  /// Copy a Flutter asset to a temporary file and return its absolute path.
  Future<String> _copyAssetToTemp(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final fileName = assetPath.split('/').last;
    final tempFile = File('${tempDir.path}/$fileName');
    await tempFile.writeAsBytes(
      byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      ),
    );
    return tempFile.path;
  }

  /// Set a live video wallpaper from a file path (user upload).
  Future<bool> setWallpaperFromFile({
    required String filePath,
  }) async {
    _result = const WallpaperSetResult(state: WallpaperSetState.setting);
    notifyListeners();

    try {
      if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
        await Future.delayed(const Duration(seconds: 1));
        _result = const WallpaperSetResult(
          state: WallpaperSetState.success,
          message: 'Wallpaper preview only (not supported on this platform)',
        );
        notifyListeners();
        return true;
      }

      // File is already on disk, pass directly to native
      await _channel.invokeMethod('setLiveWallpaper', {
        'videoPath': filePath,
      });

      _result = const WallpaperSetResult(
        state: WallpaperSetState.success,
        message: 'Live wallpaper set!',
      );
      notifyListeners();
      return true;
    } catch (e) {
      _result = WallpaperSetResult(
        state: WallpaperSetState.error,
        message: 'Failed to set wallpaper: ${e.toString()}',
      );
      notifyListeners();
      return false;
    }
  }

  void resetState() {
    _result = const WallpaperSetResult.idle();
    notifyListeners();
  }
}
