import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/theme/aether_theme.dart';
import 'services/asset_loading_service.dart';
import 'services/upload_wallpaper_service.dart';
import 'services/wallpaper_manager_service.dart';
import 'screens/home/home_screen.dart';

/// ─── Lorn Wallpaper ─────────────────────────────────────────────────────────
/// Premium live wallpaper app built with Flutter.
///
/// Architecture:
///   main.dart → Provider setup → HomeScreen → WallpaperViewer
///
/// Services (via Provider):
///   • AssetLoadingService — progressive .glb downloads
///   • WallpaperManagerService — native wallpaper API bridge
/// ─────────────────────────────────────────────────────────────────────────────

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation for optimal 3D viewing
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Set system UI overlay style (transparent status bar, dark nav)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AetherColors.charcoal,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const LornApp());
}

class LornApp extends StatelessWidget {
  const LornApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AssetLoadingService()),
        ChangeNotifierProvider(create: (_) => WallpaperManagerService()),
        ChangeNotifierProvider(create: (_) {
          final service = UploadWallpaperService();
          service.loadSavedUploads();
          return service;
        }),
      ],
      child: MaterialApp(
        title: 'Lorn Wallpaper',
        debugShowCheckedModeBanner: false,
        theme: AetherTheme.darkTheme,
        home: const HomeScreen(),
        builder: (context, child) {
          // Disable text scaling to preserve layout precision
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.noScaling,
            ),
            child: child!,
          );
        },
      ),
    );
  }
}
