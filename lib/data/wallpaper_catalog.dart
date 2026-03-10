import '../models/wallpaper_model.dart';

/// ─── Wallpaper Catalog ──────────────────────────────────────────────────────
/// Live wallpapers with video previews.
/// ─────────────────────────────────────────────────────────────────────────────

class WallpaperCatalog {
  WallpaperCatalog._();

  static final List<WallpaperModel> wallpapers = [
    WallpaperModel(
      id: 'girl_behind_curtains',
      name: 'Girl Behind Curtains',
      description: 'Mysterious silhouette behind flowing curtains.',
      category: WallpaperCategory.aesthetic,
      thumbnailUrl: 'assets/thumbnails/girl-behind-curtains.720x1280.mp4',
      videoUrl: 'assets/thumbnails/girl-behind-curtains.720x1280.mp4',
      modelUrl: 'assets/thumbnails/girl-behind-curtains.720x1280.mp4',
      fileSizeMb: 3.2,
      downloadCount: 18420,
      createdAt: DateTime(2025, 6, 1),
      colors: const WallpaperColors(
        primaryColor: 0xFFE0A0C0,
        accentColor: 0xFFFF6B9D,
        ambientLight: 0xFF1A0A14,
      ),
      sceneConfig: const WallpaperScene(
        autoRotationSpeed: 0.15,
        gyroSensitivity: 0.85,
        cameraDistance: 4.5,
        cameraFov: 45.0,
        lights: [
          LightConfig(x: 3, y: 5, z: 4, color: 0xFFFF6B9D, intensity: 1.2),
          LightConfig(x: -2, y: 3, z: -3, color: 0xFFE0A0C0, intensity: 0.6),
        ],
      ),
    ),
    WallpaperModel(
      id: 'wicked_grace',
      name: 'Wicked Grace',
      description: 'Dark elegance with a touch of supernatural grace.',
      category: WallpaperCategory.aesthetic,
      thumbnailUrl: 'assets/thumbnails/wicked-grace.720x1280.mp4',
      videoUrl: 'assets/thumbnails/wicked-grace.720x1280.mp4',
      modelUrl: 'assets/thumbnails/wicked-grace.720x1280.mp4',
      fileSizeMb: 4.1,
      isPremium: true,
      downloadCount: 14730,
      createdAt: DateTime(2025, 7, 15),
      colors: const WallpaperColors(
        primaryColor: 0xFF8B00FF,
        accentColor: 0xFFDA70D6,
        ambientLight: 0xFF0D001A,
      ),
      sceneConfig: const WallpaperScene(
        autoRotationSpeed: 0.2,
        gyroSensitivity: 0.9,
        cameraDistance: 5.0,
        cameraFov: 42.0,
        lights: [
          LightConfig(x: 4, y: 4, z: 3, color: 0xFF8B00FF, intensity: 1.0),
          LightConfig(x: -3, y: 2, z: -2, color: 0xFFDA70D6, intensity: 0.7),
        ],
      ),
    ),
    WallpaperModel(
      id: 'zenitsu_white',
      name: 'Zenitsu White',
      description: 'Thunder breathing — Zenitsu in his lightning form.',
      category: WallpaperCategory.anime,
      thumbnailUrl: 'assets/thumbnails/zenitsu-white.720x1280.mp4',
      videoUrl: 'assets/thumbnails/zenitsu-white.720x1280.mp4',
      modelUrl: 'assets/thumbnails/zenitsu-white.720x1280.mp4',
      fileSizeMb: 3.8,
      downloadCount: 25600,
      createdAt: DateTime(2025, 5, 20),
      colors: const WallpaperColors(
        primaryColor: 0xFFFFD700,
        accentColor: 0xFFFFA500,
        ambientLight: 0xFF1A1400,
      ),
      sceneConfig: const WallpaperScene(
        autoRotationSpeed: 0.35,
        gyroSensitivity: 0.75,
        cameraDistance: 5.5,
        cameraFov: 50.0,
        lights: [
          LightConfig(x: 5, y: 5, z: 5, color: 0xFFFFD700, intensity: 1.5),
          LightConfig(x: -4, y: -1, z: 3, color: 0xFFFFA500, intensity: 0.5),
        ],
      ),
    ),
  ];
}
