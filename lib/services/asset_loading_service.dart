import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/wallpaper_model.dart';

/// ─── Asset Loading Service ──────────────────────────────────────────────────
/// Progressive asset loader optimized for Indian 5G/4G networks.
/// Implements chunked downloading with progress tracking.
/// ─────────────────────────────────────────────────────────────────────────────

enum AssetLoadState { idle, downloading, cached, error }

class AssetProgress {
  final AssetLoadState state;
  final double progress; // 0.0 - 1.0
  final String? localPath;
  final String? error;

  const AssetProgress({
    required this.state,
    this.progress = 0.0,
    this.localPath,
    this.error,
  });

  const AssetProgress.idle()
      : state = AssetLoadState.idle,
        progress = 0.0,
        localPath = null,
        error = null;

  const AssetProgress.cached(this.localPath)
      : state = AssetLoadState.cached,
        progress = 1.0,
        error = null;

  AssetProgress copyWith({
    AssetLoadState? state,
    double? progress,
    String? localPath,
    String? error,
  }) {
    return AssetProgress(
      state: state ?? this.state,
      progress: progress ?? this.progress,
      localPath: localPath ?? this.localPath,
      error: error ?? this.error,
    );
  }
}

class AssetLoadingService extends ChangeNotifier {
  final Map<String, AssetProgress> _assetStates = {};
  final Map<String, Completer<String>> _downloadCompleters = {};

  AssetProgress getProgress(String assetId) {
    return _assetStates[assetId] ?? const AssetProgress.idle();
  }

  /// Check if asset is already cached locally.
  Future<String?> getCachedPath(String assetId) async {
    final dir = await _getCacheDirectory();
    final file = File('${dir.path}/$assetId.glb');
    if (await file.exists()) {
      _assetStates[assetId] = AssetProgress.cached(file.path);
      notifyListeners();
      return file.path;
    }
    return null;
  }

  /// Download a .glb model with progressive loading and progress tracking.
  /// Returns the local file path on success.
  Future<String> downloadModel(WallpaperModel wallpaper) async {
    final assetId = wallpaper.id;

    // Return cached path if available
    final cached = await getCachedPath(assetId);
    if (cached != null) return cached;

    // Prevent duplicate downloads
    if (_downloadCompleters.containsKey(assetId)) {
      return _downloadCompleters[assetId]!.future;
    }

    final completer = Completer<String>();
    _downloadCompleters[assetId] = completer;

    _updateState(assetId, const AssetProgress(
      state: AssetLoadState.downloading,
      progress: 0.0,
    ));

    try {
      final dir = await _getCacheDirectory();
      final filePath = '${dir.path}/$assetId.glb';
      final file = File(filePath);

      // For local assets (bundled models), copy directly
      if (wallpaper.modelUrl.startsWith('assets/')) {
        // In production, load from bundle; here we simulate progressive load
        await _simulateProgressiveDownload(assetId, wallpaper.fileSizeMb);
        _updateState(assetId, AssetProgress.cached(filePath));
        completer.complete(filePath);
      } else {
        // Network download with chunked progress
        final request = http.Request('GET', Uri.parse(wallpaper.modelUrl));
        final response = await http.Client().send(request);

        final totalBytes = response.contentLength ?? 0;
        int receivedBytes = 0;
        final sink = file.openWrite();

        await response.stream.listen(
          (chunk) {
            sink.add(chunk);
            receivedBytes += chunk.length;
            if (totalBytes > 0) {
              _updateState(assetId, AssetProgress(
                state: AssetLoadState.downloading,
                progress: receivedBytes / totalBytes,
              ));
            }
          },
          onDone: () async {
            await sink.close();
            _updateState(assetId, AssetProgress.cached(filePath));
            completer.complete(filePath);
          },
          onError: (error) {
            _updateState(assetId, AssetProgress(
              state: AssetLoadState.error,
              error: error.toString(),
            ));
            completer.completeError(error);
          },
        );
      }
    } catch (e) {
      _updateState(assetId, AssetProgress(
        state: AssetLoadState.error,
        error: e.toString(),
      ));
      completer.completeError(e);
    } finally {
      _downloadCompleters.remove(assetId);
    }

    return completer.future;
  }

  /// Simulate progressive download for bundled assets (dev/demo).
  Future<void> _simulateProgressiveDownload(
    String assetId,
    double sizeMb,
  ) async {
    const steps = 20;
    // Simulate ~50ms per MB chunk on 4G (realistic for India)
    final delayPerStep = Duration(
      milliseconds: (sizeMb * 50 / steps).round().clamp(10, 100),
    );

    for (int i = 1; i <= steps; i++) {
      await Future.delayed(delayPerStep);
      _updateState(assetId, AssetProgress(
        state: AssetLoadState.downloading,
        progress: i / steps,
      ));
    }
  }

  void _updateState(String assetId, AssetProgress progress) {
    _assetStates[assetId] = progress;
    notifyListeners();
  }

  Future<Directory> _getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/aether_models');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  /// Clear all cached models.
  Future<void> clearCache() async {
    final dir = await _getCacheDirectory();
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
    _assetStates.clear();
    notifyListeners();
  }

  /// Get total cache size in MB.
  Future<double> getCacheSizeMb() async {
    final dir = await _getCacheDirectory();
    if (!await dir.exists()) return 0.0;

    int totalBytes = 0;
    await for (final entity in dir.list()) {
      if (entity is File) {
        totalBytes += await entity.length();
      }
    }
    return totalBytes / (1024 * 1024);
  }
}
