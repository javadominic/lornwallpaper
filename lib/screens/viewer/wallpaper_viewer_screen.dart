import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/aether_theme.dart';
import '../../models/wallpaper_model.dart';
import '../../services/wallpaper_manager_service.dart';
import '../../widgets/action_drawer.dart';
import '../../widgets/video_thumbnail.dart';

/// ─── Wallpaper Viewer Screen ────────────────────────────────────────────────
/// Full-screen immersive video wallpaper viewer with:
///   • Looping video playback
///   • Tap to reveal action drawer
///   • Set as wallpaper button
/// ─────────────────────────────────────────────────────────────────────────────

class WallpaperViewerScreen extends StatefulWidget {
  final WallpaperModel wallpaper;

  const WallpaperViewerScreen({
    super.key,
    required this.wallpaper,
  });

  @override
  State<WallpaperViewerScreen> createState() => _WallpaperViewerScreenState();
}

class _WallpaperViewerScreenState extends State<WallpaperViewerScreen>
    with SingleTickerProviderStateMixin {
  bool _showUI = true;
  late AnimationController _uiAnimController;
  late Animation<double> _uiOpacity;

  @override
  void initState() {
    super.initState();

    // Force immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _uiAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0, // start visible
    );
    _uiOpacity = CurvedAnimation(
      parent: _uiAnimController,
      curve: Curves.easeOut,
    );

    // Auto-hide UI after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _showUI) _toggleUI();
    });
  }

  void _toggleUI() {
    setState(() => _showUI = !_showUI);
    if (_showUI) {
      _uiAnimController.forward();
    } else {
      _uiAnimController.reverse();
    }
  }

  void _showActionDrawerSheet() {
    final wallpaperService = context.read<WallpaperManagerService>();

    showActionDrawer(
      context: context,
      wallpaper: widget.wallpaper,
      onSetWallpaper: () async {
        await wallpaperService.setWallpaper(
          videoAssetPath: widget.wallpaper.videoUrl ?? '',
        );
      },
    );
  }

  @override
  void dispose() {
    _uiAnimController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AetherColors.charcoal,
      body: GestureDetector(
        onTap: _toggleUI,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Full-screen video
            Hero(
              tag: 'wallpaper_${widget.wallpaper.id}',
              child: widget.wallpaper.videoUrl != null
                  ? FullScreenVideoPlayer(
                      assetPath: widget.wallpaper.videoUrl!,
                    )
                  : Container(color: AetherColors.charcoal),
            ),

            // Top gradient for status bar readability
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 120,
              child: FadeTransition(
                opacity: _uiOpacity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AetherColors.charcoal.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Back button & title
            Positioned(
              top: MediaQuery.of(context).padding.top + AetherSpacing.sm,
              left: AetherSpacing.sm,
              right: AetherSpacing.md,
              child: FadeTransition(
                opacity: _uiOpacity,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AetherColors.charcoal.withOpacity(0.6),
                          border: Border.all(
                            color: AetherColors.white10,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: AetherColors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: AetherSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.wallpaper.name,
                            style: const TextStyle(
                              color: AetherColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'SpaceGrotesk',
                            ),
                          ),
                          Text(
                            widget.wallpaper.category.name.toUpperCase(),
                            style: const TextStyle(
                              color: AetherColors.electricCyanDim,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2.0,
                              fontFamily: 'SpaceGrotesk',
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Video indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AetherColors.charcoal.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(AetherRadius.pill),
                        border: Border.all(
                          color: AetherColors.electricCyan.withOpacity(0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.play_circle_outline_rounded,
                            size: 14,
                            color: AetherColors.electricCyan,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'LIVE',
                            style: TextStyle(
                              color: AetherColors.electricCyan,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              fontFamily: 'SpaceGrotesk',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom gradient
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 180,
              child: FadeTransition(
                opacity: _uiOpacity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AetherColors.charcoal.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom action button
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + AetherSpacing.lg,
              left: AetherSpacing.xl,
              right: AetherSpacing.xl,
              child: FadeTransition(
                opacity: _uiOpacity,
                child: _buildBottomActions(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // "Set as Wallpaper" main CTA
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _showActionDrawerSheet,
            style: ElevatedButton.styleFrom(
              backgroundColor: AetherColors.electricCyan,
              foregroundColor: AetherColors.charcoal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AetherRadius.md),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wallpaper_rounded, size: 22),
                SizedBox(width: AetherSpacing.sm),
                Text(
                  'Set as Live Wallpaper',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'SpaceGrotesk',
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AetherSpacing.md),
        // Info row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildInfoChip(
              Icons.straighten_rounded,
              '${widget.wallpaper.fileSizeMb.toStringAsFixed(1)} MB',
            ),
            const SizedBox(width: AetherSpacing.md),
            _buildInfoChip(
              Icons.download_rounded,
              _formatCount(widget.wallpaper.downloadCount),
            ),
            const SizedBox(width: AetherSpacing.md),
            _buildInfoChip(
              Icons.play_circle_rounded,
              'VIDEO',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AetherColors.white05,
        borderRadius: BorderRadius.circular(AetherRadius.pill),
        border: Border.all(color: AetherColors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AetherColors.white30),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AetherColors.white50,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              fontFamily: 'SpaceGrotesk',
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}
