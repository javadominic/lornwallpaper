import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../core/theme/aether_theme.dart';

/// ─── Shimmer Loading Widgets ────────────────────────────────────────────────
/// Premium shimmer effects for initial texture/model downloads.
/// Matches the Charcoal/Cyan aesthetic.
/// ─────────────────────────────────────────────────────────────────────────────

class AetherShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const AetherShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AetherColors.charcoalSurface,
      highlightColor: AetherColors.electricCyan.withOpacity(0.08),
      period: const Duration(milliseconds: 1800),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AetherColors.charcoalSurface,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Full grid shimmer placeholder while wallpapers are loading.
class WallpaperGridShimmer extends StatelessWidget {
  final int itemCount;

  const WallpaperGridShimmer({
    super.key,
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AetherSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AetherSpacing.md,
        crossAxisSpacing: AetherSpacing.md,
        childAspectRatio: 0.75,
      ),
      itemCount: itemCount,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return _ShimmerCard(index: index);
      },
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  final int index;

  const _ShimmerCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AetherColors.charcoalSurface,
      highlightColor: AetherColors.electricCyan.withOpacity(0.06),
      period: Duration(milliseconds: 1500 + (index * 200)),
      child: Container(
        decoration: BoxDecoration(
          color: AetherColors.charcoalSurface,
          borderRadius: BorderRadius.circular(AetherRadius.lg),
          border: Border.all(
            color: AetherColors.white10,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail area
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AetherColors.charcoalLight,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AetherRadius.lg),
                  ),
                ),
              ),
            ),
            // Info area
            Padding(
              padding: const EdgeInsets.all(AetherSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12,
                    width: 80,
                    decoration: BoxDecoration(
                      color: AetherColors.charcoalLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 10,
                    width: 50,
                    decoration: BoxDecoration(
                      color: AetherColors.charcoalLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Inline shimmer for a download progress indicator.
class DownloadProgressShimmer extends StatelessWidget {
  final double progress;

  const DownloadProgressShimmer({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(AetherRadius.pill),
          child: SizedBox(
            height: 4,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AetherColors.charcoalSurface,
              valueColor: const AlwaysStoppedAnimation(
                AetherColors.electricCyan,
              ),
            ),
          ),
        ),
        const SizedBox(height: AetherSpacing.xs),
        Text(
          '${(progress * 100).toInt()}%',
          style: const TextStyle(
            color: AetherColors.electricCyanDim,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
