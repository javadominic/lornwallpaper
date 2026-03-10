/// ─── Wallpaper Model ─────────────────────────────────────────────────────────
/// Represents a 3D live wallpaper with all required metadata.
/// ─────────────────────────────────────────────────────────────────────────────

enum WallpaperCategory {
  anime,
  aesthetic,
  nature,
  abstract,
  space,
}

class WallpaperModel {
  final String id;
  final String name;
  final String description;
  final WallpaperCategory category;
  final String thumbnailUrl;
  final String? videoUrl; // local video preview path
  final String modelUrl; // .glb file URL
  final String? localModelPath;
  final double fileSizeMb;
  final bool isPremium;
  final int downloadCount;
  final DateTime createdAt;
  final WallpaperColors colors;
  final WallpaperScene sceneConfig;

  const WallpaperModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.thumbnailUrl,
    this.videoUrl,
    required this.modelUrl,
    this.localModelPath,
    required this.fileSizeMb,
    this.isPremium = false,
    this.downloadCount = 0,
    required this.createdAt,
    required this.colors,
    required this.sceneConfig,
  });

  WallpaperModel copyWith({
    String? localModelPath,
  }) {
    return WallpaperModel(
      id: id,
      name: name,
      description: description,
      category: category,
      thumbnailUrl: thumbnailUrl,
      videoUrl: videoUrl,
      modelUrl: modelUrl,
      localModelPath: localModelPath ?? this.localModelPath,
      fileSizeMb: fileSizeMb,
      isPremium: isPremium,
      downloadCount: downloadCount,
      createdAt: createdAt,
      colors: colors,
      sceneConfig: sceneConfig,
    );
  }
}

class WallpaperColors {
  final int primaryColor;
  final int accentColor;
  final int ambientLight;

  const WallpaperColors({
    required this.primaryColor,
    required this.accentColor,
    required this.ambientLight,
  });
}

class WallpaperScene {
  final double autoRotationSpeed; // radians per second
  final double gyroSensitivity;
  final double cameraDistance;
  final double cameraFov;
  final List<LightConfig> lights;

  const WallpaperScene({
    this.autoRotationSpeed = 0.3,
    this.gyroSensitivity = 0.8,
    this.cameraDistance = 5.0,
    this.cameraFov = 45.0,
    this.lights = const [],
  });
}

class LightConfig {
  final double x, y, z;
  final int color;
  final double intensity;

  const LightConfig({
    required this.x,
    required this.y,
    required this.z,
    required this.color,
    this.intensity = 1.0,
  });
}
