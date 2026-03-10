# ✦ Lorn Wallpaper

> Live Video Wallpapers for Android — Built with Flutter + Native Kotlin WallpaperService

![Flutter](https://img.shields.io/badge/Flutter-3.19+-02569B?style=flat&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.2+-0175C2?style=flat&logo=dart)
![Android](https://img.shields.io/badge/Android-API%2024+-3DDC84?style=flat&logo=android)
![Kotlin](https://img.shields.io/badge/Kotlin-Native%20Service-7F52FF?style=flat&logo=kotlin)

---

## 🎨 Design

**Aesthetic:** Premium Minimalist  
**Palette:** Charcoal `#121212` + Electric Cyan `#00FFFF`  
**UI Pattern:** Glassmorphism with frosted-glass cards & subtle cyan glow accents

---

## ✨ Features

### 🎬 Live Video Wallpapers
- Set any MP4 video as a **live wallpaper** on your Android device
- Instant playback — video starts immediately when screen turns on (no loading delay)
- Loops seamlessly, plays silently in the background
- Applies to both Home Screen & Lock Screen

### 📤 Upload Your Own
- Pick any MP4 file from your device using the **+** button
- **20 MB** max file size, **15 seconds** max duration
- Uploads are validated, stored locally, and persist across app restarts
- Long-press to delete an upload

### 🖼️ Built-in Wallpaper Collection
- 3 curated video wallpapers included:
  - **Girl Behind Curtains** — aesthetic
  - **Wicked Grace** — aesthetic / premium
  - **Zenitsu White** — anime
- Category filter chips (All, Anime, Aesthetic, Nature, Abstract, Space)
- Full-screen video preview before setting

### 🧊 Glassmorphism UI
- Frosted-glass bottom sheet action drawer
- Pulsing cyan glow CTA button with loading / success states
- Shimmer loading effects
- Immersive full-screen video viewer with auto-hiding controls

---

## 🏗️ Architecture

```
lib/
├── main.dart                              # App entry + Provider setup
├── core/theme/
│   ├── aether_theme.dart                  # Colors, spacing, typography
│   └── glass_card.dart                    # Glassmorphism widgets
├── models/
│   └── wallpaper_model.dart               # WallpaperModel, scene config
├── data/
│   └── wallpaper_catalog.dart             # 3 built-in wallpapers
├── services/
│   ├── asset_loading_service.dart         # Asset progress tracking
│   ├── gyroscope_service.dart             # Sensor pipeline
│   ├── wallpaper_manager_service.dart     # Platform channel → native wallpaper API
│   └── upload_wallpaper_service.dart      # File picking, validation, storage
├── widgets/
│   ├── video_thumbnail.dart               # VideoThumbnail + FullScreenVideoPlayer
│   ├── action_drawer.dart                 # Glassmorphism bottom sheet
│   ├── shimmer_loading.dart               # Shimmer effects
│   └── grid/
│       └── wallpaper_grid_card.dart       # Grid card with video preview
└── screens/
    ├── home/
    │   └── home_screen.dart               # Grid + category chips + upload section
    └── viewer/
        ├── wallpaper_viewer_screen.dart    # Full-screen viewer (built-in)
        └── upload_viewer_screen.dart       # Full-screen viewer (user uploads)

android/.../kotlin/com/lorn/wallpaper/
├── MainActivity.kt                        # Flutter ↔ Native platform channel
└── VideoLiveWallpaperService.kt           # Android WallpaperService (MediaPlayer)
```

---

## 🔧 How the Live Wallpaper Works

```
Flutter App                          Android Native
─────────                            ──────────────
User taps "Set as Live Wallpaper"
        │
        ▼
MethodChannel('com.lorn.wallpaper/wallpaper')
        │
        ▼
MainActivity.kt
  • Copies MP4 to internal storage
  • Saves path + bumps version in SharedPreferences
  • Launches ACTION_CHANGE_LIVE_WALLPAPER intent
        │
        ▼
VideoLiveWallpaperService.kt (WallpaperService)
  • MediaPlayer renders to SurfaceHolder
  • Synchronous prepare() for instant start
  • On screen off → pause() (keeps player alive)
  • On screen on → seekTo(0) + start() (instant resume)
  • Version tracking detects wallpaper changes
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.19+
- Dart SDK 3.2+
- Android SDK (API 24+, compileSdk 36)
- JDK 17

### Setup

```bash
# 1. Clone the repo
git clone https://github.com/javadominic/lornwallpaper.git
cd lornwallpaper

# 2. Install dependencies
flutter pub get

# 3. Run on device/emulator
flutter run

# 4. Build debug APK
flutter build apk --debug
```

### Adding Your Own Built-in Wallpapers

1. Place your `.mp4` file in `assets/thumbnails/`
2. Add an entry to `lib/data/wallpaper_catalog.dart`
3. Set the `videoUrl` field to `'assets/thumbnails/your_file.mp4'`

---

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| `video_player` | Video playback for previews |
| `file_picker` | User MP4 file selection |
| `provider` | State management |
| `path_provider` | App directory access |
| `permission_handler` | Runtime permissions |
| `sensors_plus` | Gyroscope / accelerometer |
| `shimmer` | Loading shimmer effects |
| `google_fonts` | SpaceGrotesk typography |
| `vector_math` | Math utilities |

---

## 📱 Upload Limits

| Constraint | Limit |
|------------|-------|
| File format | `.mp4` only |
| Max file size | **20 MB** |
| Max duration | **15 seconds** |

---

## 🔋 Performance

- **Instant resume**: MediaPlayer stays alive (pause/resume, no re-create)
- **Synchronous prepare()**: Local file playback starts with zero async overhead
- **Version tracking**: SharedPreferences version counter detects wallpaper changes without path comparison
- **Battery**: Video pauses on screen off, no background CPU usage

---

## License

MIT
