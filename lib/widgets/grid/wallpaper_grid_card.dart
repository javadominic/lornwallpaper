import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/aether_theme.dart';
import '../../models/wallpaper_model.dart';
import '../../services/asset_loading_service.dart';
import '../shimmer_loading.dart';
import '../video_thumbnail.dart';

/// ─── Wallpaper Grid Card ────────────────────────────────────────────────────
/// Glassmorphism card with video preview thumbnail.
/// Shows shimmer during load, then plays video preview in a loop.
/// ─────────────────────────────────────────────────────────────────────────────

class WallpaperGridCard extends StatelessWidget {
  final WallpaperModel wallpaper;
  final AssetProgress assetProgress;
  final VoidCallback onTap;

  const WallpaperGridCard({
    super.key,
    required this.wallpaper,
    required this.assetProgress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'wallpaper_${wallpaper.id}',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AetherRadius.lg),
            boxShadow: AetherShadows.subtleCyanGlow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AetherRadius.lg),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Video Preview
                _buildPreviewLayer(),

                // Glass overlay with info
                _buildInfoOverlay(context),

                // Premium badge
                if (wallpaper.isPremium) _buildPremiumBadge(),

                // Download progress overlay
                if (assetProgress.state == AssetLoadState.downloading)
                  _buildDownloadOverlay(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewLayer() {
    // Use video preview if available
    if (wallpaper.videoUrl != null) {
      return VideoThumbnail(
        assetPath: wallpaper.videoUrl!,
        fit: BoxFit.cover,
      );
    }

    // Fallback colored placeholder
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(wallpaper.colors.primaryColor).withOpacity(0.6),
            Color(wallpaper.colors.ambientLight),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.wallpaper_rounded,
          color: Color(wallpaper.colors.primaryColor).withOpacity(0.3),
          size: 48,
        ),
      ),
    );
  }

  Widget _buildInfoOverlay(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AetherRadius.lg),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AetherSpacing.sm + 2,
              vertical: AetherSpacing.sm,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AetherColors.charcoal.withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  wallpaper.name,
                  style: const TextStyle(
                    color: AetherColors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SpaceGrotesk',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.download_rounded,
                      size: 11,
                      color: AetherColors.white30,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      _formatDownloads(wallpaper.downloadCount),
                      style: const TextStyle(
                        color: AetherColors.white30,
                        fontSize: 10,
                        fontFamily: 'SpaceGrotesk',
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${wallpaper.fileSizeMb.toStringAsFixed(1)} MB',
                      style: const TextStyle(
                        color: AetherColors.white30,
                        fontSize: 10,
                        fontFamily: 'SpaceGrotesk',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumBadge() {
    return Positioned(
      top: AetherSpacing.sm,
      right: AetherSpacing.sm,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 3,
        ),
        decoration: BoxDecoration(
          color: AetherColors.electricCyan.withOpacity(0.9),
          borderRadius: BorderRadius.circular(AetherRadius.sm),
          boxShadow: AetherShadows.subtleCyanGlow,
        ),
        child: const Text(
          'PRO',
          style: TextStyle(
            color: AetherColors.charcoal,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            fontFamily: 'SpaceGrotesk',
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadOverlay() {
    return Positioned.fill(
      child: Container(
        color: AetherColors.charcoal.withOpacity(0.7),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AetherSpacing.lg),
            child: DownloadProgressShimmer(
              progress: assetProgress.progress,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDownloads(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}
