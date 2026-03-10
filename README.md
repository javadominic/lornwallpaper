# ✦ Aether Live Wallpapers

> Premium 3D Live Wallpapers with Gyroscope Parallax — Built with Flutter & Impeller

![Flutter](https://img.shields.io/badge/Flutter-3.19+-02569B?style=flat&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.2+-0175C2?style=flat&logo=dart)
![Impeller](https://img.shields.io/badge/Renderer-Impeller-00FFFF?style=flat)

---

## 🎨 Design

**Aesthetic:** Premium Minimalist  
**Palette:** Charcoal `#121212` + Electric Cyan `#00FFFF`  
**UI Pattern:** Glassmorphism with frosted-glass cards & subtle cyan glow accents

---

## 🏗️ Architecture

```
lib/
├── main.dart                          # App entry point & Provider setup
├── core/
│   └── theme/
│       ├── aether_theme.dart          # Colors, typography, theme data
│       └── glass_card.dart            # Glassmorphism reusable widgets
├── models/
│   └── wallpaper_model.dart           # WallpaperModel, scene config, lights
├── data/
│   └── wallpaper_catalog.dart         # Sample wallpaper catalog (6 wallpapers)
├── services/
│   ├── asset_loading_service.dart     # Progressive .glb download with progress
│   ├── gyroscope_service.dart         # Sensor → 3D rotation pipeline
│   └── wallpaper_manager_service.dart # Native wallpaper API bridge
├── rendering/
│   └── aether_scene_renderer.dart     # 3D scene: crystal rendering, lighting, camera
├── widgets/
│   ├── shimmer_loading.dart           # Shimmer effects for loading states
│   ├── action_drawer.dart             # Bottom sheet with wallpaper controls
│   └── grid/
│       └── wallpaper_grid_card.dart   # Glassmorphism grid card with 3D preview
└── screens/
    ├── home/
    │   └── home_screen.dart           # Homepage with category filter + grid
    └── viewer/
        └── wallpaper_viewer_screen.dart  # Full-screen 3D viewer + gyro parallax
```

---

## ✨ Features

### 3D Crystal Rendering
- Procedural low-poly crystal geometry with 3D projection
- Per-face diffuse lighting with configurable light sources
- Painter's algorithm for correct face ordering
- Ambient floating particles and lens flare effects
- `RepaintBoundary` for GPU-optimized repainting

### Gyroscope Parallax
```
Accelerometer + Gyroscope → Low-pass Filter → Smooth Lerp → Camera Matrix → Scene Render
```
- Combines accelerometer (absolute tilt) with gyroscope (angular velocity)
- Configurable sensitivity per wallpaper
- 30° max rotation clamp to prevent disorientation
- Smooth interpolation factor of 0.12 for fluid, lag-free parallax

### Progressive Asset Loading
- Chunked HTTP download with real-time progress tracking
- Local file caching in app documents directory
- Shimmer loading effects during initial texture downloads
- Optimized for Indian 4G/5G bandwidth profiles

### Action Drawer
- Glassmorphism bottom sheet with `BackdropFilter` blur
- Home Screen / Lock Screen toggle switches
- Pulsing cyan glow CTA button
- Loading → Success → Error state transitions

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.19+ (with Impeller support)
- Dart SDK 3.2+
- Android Studio / Xcode
- Physical device with gyroscope (recommended)

### Setup

```bash
# 1. Install dependencies
flutter pub get

# 2. Add your .glb 3D models to assets/models/
#    (crystal_cyan.glb, crystal_amethyst.glb, etc.)

# 3. Add thumbnail images to assets/thumbnails/
#    (crystal_cyan.webp, etc.)

# 4. Add SpaceGrotesk font files to assets/fonts/
#    Download from: https://fonts.google.com/specimen/Space+Grotesk

# 5. Run with Impeller enabled
flutter run --enable-impeller
```

### Building for Release

```bash
# Android APK
flutter build apk --release --enable-impeller

# Android App Bundle
flutter build appbundle --release --enable-impeller

# iOS
flutter build ios --release
```

---

## ⚙️ Impeller Configuration

Impeller is enabled in two places:

**Android** — `AndroidManifest.xml`:
```xml
<meta-data
    android:name="io.flutter.embedding.android.EnableImpeller"
    android:value="true" />
```

**iOS** — `Info.plist`:
```xml
<key>FLTEnableImpeller</key>
<true/>
```

---

## 📦 Key Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_scene` | Native 3D .glb model rendering |
| `sensors_plus` | Gyroscope & accelerometer access |
| `flutter_wallpaper_manager` | Android live wallpaper API |
| `vector_math` | 3D matrix/vector math for camera transforms |
| `shimmer` | Loading shimmer effects |
| `provider` | State management |
| `cached_network_image` | Image caching |
| `permission_handler` | Runtime permission requests |

---

## 🔋 Performance Notes

- **Frame budget:** 60fps target via `Ticker` with dt-based updates
- **Battery optimization:** Preview mode uses reduced particle count and no gyro
- **Render isolation:** `RepaintBoundary` isolates 3D canvas from UI tree
- **Memory:** Painter's algorithm avoids Z-buffer memory overhead
- **Network:** Progressive chunked downloads with ~50ms/MB simulation for 4G

---

## 📝 Adding New Wallpapers

1. Create a `.glb` model (Blender recommended, keep poly count < 5000)
2. Add entry to `lib/data/wallpaper_catalog.dart`
3. Configure `WallpaperScene` with lighting and rotation parameters
4. Place `.glb` in `assets/models/` and thumbnail in `assets/thumbnails/`

---

## License

MIT
