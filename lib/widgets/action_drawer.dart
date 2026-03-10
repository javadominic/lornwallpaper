import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/aether_theme.dart';
import '../models/wallpaper_model.dart';
import '../services/wallpaper_manager_service.dart';

/// ─── Action Drawer ──────────────────────────────────────────────────────────
/// Semi-transparent glassmorphism bottom sheet with:
///   • "Set as Live Wallpaper" button
///   • Wallpaper info
///   • Note: Android live wallpapers apply to both home & lock screens
/// ─────────────────────────────────────────────────────────────────────────────

class ActionDrawer extends StatefulWidget {
  final WallpaperModel wallpaper;
  final VoidCallback? onSetWallpaper;
  final WallpaperSetState setWallpaperState;

  const ActionDrawer({
    super.key,
    required this.wallpaper,
    this.onSetWallpaper,
    this.setWallpaperState = WallpaperSetState.idle,
  });

  @override
  State<ActionDrawer> createState() => _ActionDrawerState();
}

class _ActionDrawerState extends State<ActionDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AetherRadius.xl),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          decoration: BoxDecoration(
            color: AetherColors.charcoal.withOpacity(0.85),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AetherRadius.xl),
            ),
            border: Border(
              top: BorderSide(
                color: AetherColors.electricCyan.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          padding: EdgeInsets.only(
            left: AetherSpacing.lg,
            right: AetherSpacing.lg,
            top: AetherSpacing.md,
            bottom: bottomPadding + AetherSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              _buildDragHandle(),
              const SizedBox(height: AetherSpacing.lg),

              // Wallpaper info
              _buildWallpaperInfo(),
              const SizedBox(height: AetherSpacing.lg),

              // Divider
              Container(
                height: 1,
                color: AetherColors.white10,
              ),
              const SizedBox(height: AetherSpacing.lg),

              // Info row
              Row(
                children: [
                  Icon(
                    Icons.home_rounded,
                    color: AetherColors.electricCyan,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.lock_rounded,
                    color: AetherColors.electricCyan,
                    size: 18,
                  ),
                  const SizedBox(width: AetherSpacing.sm),
                  Expanded(
                    child: Text(
                      'Applies to Home & Lock Screen',
                      style: TextStyle(
                        color: AetherColors.white50,
                        fontSize: 13,
                        fontFamily: 'SpaceGrotesk',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AetherSpacing.xl),

              // Set Wallpaper Button
              _buildSetWallpaperButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AetherColors.white30,
          borderRadius: BorderRadius.circular(AetherRadius.pill),
        ),
      ),
    );
  }

  Widget _buildWallpaperInfo() {
    return Row(
      children: [
        // Color accent dot
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Color(widget.wallpaper.colors.primaryColor),
                Color(widget.wallpaper.colors.accentColor),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(widget.wallpaper.colors.primaryColor)
                    .withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: AetherSpacing.md),
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
              const SizedBox(height: 2),
              Text(
                widget.wallpaper.description,
                style: const TextStyle(
                  color: AetherColors.white50,
                  fontSize: 13,
                  fontFamily: 'SpaceGrotesk',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSetWallpaperButton() {
    final isLoading =
        widget.setWallpaperState == WallpaperSetState.setting;
    final isSuccess =
        widget.setWallpaperState == WallpaperSetState.success;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AetherRadius.md),
              boxShadow: [
                BoxShadow(
                  color: AetherColors.electricCyan
                      .withOpacity(0.2 + _pulseAnimation.value * 0.15),
                  blurRadius: 16 + _pulseAnimation.value * 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: child,
          );
        },
        child: ElevatedButton(
          onPressed: isLoading
              ? null
              : () => widget.onSetWallpaper?.call(),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSuccess
                ? AetherColors.success
                : AetherColors.electricCyan,
            foregroundColor: AetherColors.charcoal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AetherRadius.md),
            ),
            elevation: 0,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(
                      AetherColors.charcoal,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isSuccess
                          ? Icons.check_circle_rounded
                          : Icons.wallpaper_rounded,
                      size: 22,
                    ),
                    const SizedBox(width: AetherSpacing.sm),
                    Text(
                      isSuccess
                          ? 'Wallpaper Set!'
                          : 'Set as Live Wallpaper',
                      style: const TextStyle(
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
    );
  }
}

/// Convenience function to show the ActionDrawer as a modal bottom sheet.
Future<void> showActionDrawer({
  required BuildContext context,
  required WallpaperModel wallpaper,
  required Future<void> Function() onSetWallpaper,
}) async {
  WallpaperSetState currentState = WallpaperSetState.idle;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return ActionDrawer(
            wallpaper: wallpaper,
            setWallpaperState: currentState,
            onSetWallpaper: () async {
              setSheetState(
                () => currentState = WallpaperSetState.setting,
              );
              try {
                await onSetWallpaper();
                setSheetState(
                  () => currentState = WallpaperSetState.success,
                );
                await Future.delayed(const Duration(seconds: 1));
                if (context.mounted) Navigator.pop(context);
              } catch (_) {
                setSheetState(
                  () => currentState = WallpaperSetState.error,
                );
              }
            },
          );
        },
      );
    },
  );
}
