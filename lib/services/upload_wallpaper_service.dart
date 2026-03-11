import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

/// ─── Upload Wallpaper Service ───────────────────────────────────────────────
/// Handles picking, validating, and storing user-uploaded MP4 files.
/// Limits: 20 MB max file size, 15 seconds max duration.
/// ─────────────────────────────────────────────────────────────────────────────

class UploadValidationResult {
  final bool isValid;
  final String? error;
  final String? filePath;
  final double? sizeMb;
  final Duration? duration;

  const UploadValidationResult({
    required this.isValid,
    this.error,
    this.filePath,
    this.sizeMb,
    this.duration,
  });
}

class UploadWallpaperService extends ChangeNotifier {
  static const double maxSizeMb = 30.0;
  static const int maxDurationSeconds = 50;

  final List<UploadedWallpaper> _uploads = [];
  List<UploadedWallpaper> get uploads => List.unmodifiable(_uploads);

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Initialize — load previously saved uploads from app storage.
  Future<void> loadSavedUploads() async {
    final dir = await _uploadsDir();
    if (!dir.existsSync()) return;

    final files = dir.listSync().whereType<File>().where(
          (f) => f.path.endsWith('.mp4'),
        );

    for (final file in files) {
      final name = file.uri.pathSegments.last.replaceAll('.mp4', '');
      final stat = file.statSync();
      final sizeMb = stat.size / (1024 * 1024);
      _uploads.add(UploadedWallpaper(
        name: _prettifyName(name),
        filePath: file.path,
        sizeMb: sizeMb,
        addedAt: stat.modified,
      ));
    }
    notifyListeners();
  }

  /// Pick an MP4 file, validate size & duration, copy to app storage.
  Future<UploadValidationResult> pickAndValidate() async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp4'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty || result.files.first.path == null) {
        _isProcessing = false;
        notifyListeners();
        return const UploadValidationResult(
          isValid: false,
          error: 'No file selected.',
        );
      }

      final pickedPath = result.files.first.path!;
      final file = File(pickedPath);

      // 2. Validate file size
      final sizeBytes = await file.length();
      final sizeMb = sizeBytes / (1024 * 1024);
      if (sizeMb > maxSizeMb) {
        _isProcessing = false;
        _errorMessage = 'File too large (${sizeMb.toStringAsFixed(1)} MB). Max is ${maxSizeMb.toInt()} MB.';
        notifyListeners();
        return UploadValidationResult(
          isValid: false,
          error: _errorMessage,
        );
      }

      // 3. Validate duration using video_player
      Duration? duration;
      try {
        final controller = VideoPlayerController.file(file);
        await controller.initialize();
        duration = controller.value.duration;
        await controller.dispose();
      } catch (e) {
        _isProcessing = false;
        _errorMessage = 'Could not read video. Make sure it\'s a valid MP4.';
        notifyListeners();
        return UploadValidationResult(
          isValid: false,
          error: _errorMessage,
        );
      }

      if (duration != null && duration.inSeconds > maxDurationSeconds) {
        _isProcessing = false;
        _errorMessage =
            'Video too long (${duration.inSeconds}s). Max is ${maxDurationSeconds}s.';
        notifyListeners();
        return UploadValidationResult(
          isValid: false,
          error: _errorMessage,
        );
      }

      // 4. Copy to app storage
      final uploadsDir = await _uploadsDir();
      if (!uploadsDir.existsSync()) {
        uploadsDir.createSync(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final originalName = result.files.first.name.replaceAll('.mp4', '');
      final destFileName = '${originalName}_$timestamp.mp4';
      final destFile = File('${uploadsDir.path}/$destFileName');
      await file.copy(destFile.path);

      // 5. Add to uploads list
      final uploaded = UploadedWallpaper(
        name: _prettifyName(originalName),
        filePath: destFile.path,
        sizeMb: sizeMb,
        duration: duration,
        addedAt: DateTime.now(),
      );
      _uploads.insert(0, uploaded);

      _isProcessing = false;
      _errorMessage = null;
      notifyListeners();

      return UploadValidationResult(
        isValid: true,
        filePath: destFile.path,
        sizeMb: sizeMb,
        duration: duration,
      );
    } catch (e) {
      _isProcessing = false;
      _errorMessage = 'Error: ${e.toString()}';
      notifyListeners();
      return UploadValidationResult(
        isValid: false,
        error: _errorMessage,
      );
    }
  }

  /// Delete an uploaded wallpaper.
  Future<void> deleteUpload(UploadedWallpaper upload) async {
    final file = File(upload.filePath);
    if (file.existsSync()) {
      await file.delete();
    }
    _uploads.remove(upload);
    notifyListeners();
  }

  Future<Directory> _uploadsDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/uploads');
  }

  String _prettifyName(String name) {
    // Convert snake_case/kebab-case to Title Case
    return name
        .replaceAll(RegExp(r'[_\-.]'), ' ')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }
}

class UploadedWallpaper {
  final String name;
  final String filePath;
  final double sizeMb;
  final Duration? duration;
  final DateTime addedAt;

  const UploadedWallpaper({
    required this.name,
    required this.filePath,
    required this.sizeMb,
    this.duration,
    required this.addedAt,
  });
}
