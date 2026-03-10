import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/aether_theme.dart';
import '../../services/upload_wallpaper_service.dart';
import '../../services/wallpaper_manager_service.dart';
import '../../widgets/video_thumbnail.dart';

/// ─── Upload Viewer Screen ───────────────────────────────────────────────────
/// Full-screen viewer for user-uploaded MP4 files.
/// Tap to reveal UI, set as live wallpaper.
/// ─────────────────────────────────────────────────────────────────────────────

class UploadViewerScreen extends StatefulWidget {
  final UploadedWallpaper upload;

  const UploadViewerScreen({
    super.key,
    required this.upload,
  });

  @override
  State<UploadViewerScreen> createState() => _UploadViewerScreenState();
}

class _UploadViewerScreenState extends State<UploadViewerScreen>
    with SingleTickerProviderStateMixin {
  bool _showUI = true;
  late AnimationController _uiAnimController;
  late Animation<double> _uiOpacity;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _uiAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0,
    );
    _uiOpacity = CurvedAnimation(
      parent: _uiAnimController,
      curve: Curves.easeOut,
    );

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

  void _setAsWallpaper() {
    final wallpaperService = context.read<WallpaperManagerService>();
    WallpaperSetState currentState = WallpaperSetState.idle;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final isLoading = currentState == WallpaperSetState.setting;
            final isSuccess = currentState == WallpaperSetState.success;
            final bottomPadding = MediaQuery.of(ctx).padding.bottom;

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
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AetherColors.white30,
                            borderRadius:
                                BorderRadius.circular(AetherRadius.pill),
                          ),
                        ),
                      ),
                      const SizedBox(height: AetherSpacing.lg),

                      // Upload info
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AetherColors.electricCyan.withOpacity(0.15),
                              border: Border.all(
                                color: AetherColors.electricCyan.withOpacity(0.3),
                              ),
                            ),
                            child: const Icon(
                              Icons.upload_file_rounded,
                              color: AetherColors.electricCyan,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AetherSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.upload.name,
                                  style: const TextStyle(
                                    color: AetherColors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'SpaceGrotesk',
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${widget.upload.sizeMb.toStringAsFixed(1)} MB • Your upload',
                                  style: const TextStyle(
                                    color: AetherColors.white50,
                                    fontSize: 13,
                                    fontFamily: 'SpaceGrotesk',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AetherSpacing.lg),

                      Container(height: 1, color: AetherColors.white10),
                      const SizedBox(height: AetherSpacing.lg),

                      // Info row
                      Row(
                        children: [
                          Icon(Icons.home_rounded,
                              color: AetherColors.electricCyan, size: 18),
                          const SizedBox(width: 6),
                          Icon(Icons.lock_rounded,
                              color: AetherColors.electricCyan, size: 18),
                          const SizedBox(width: AetherSpacing.sm),
                          const Expanded(
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

                      // Set button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  setSheetState(() =>
                                      currentState = WallpaperSetState.setting);
                                  try {
                                    await wallpaperService.setWallpaperFromFile(
                                      filePath: widget.upload.filePath,
                                    );
                                    setSheetState(() =>
                                        currentState = WallpaperSetState.success);
                                    await Future.delayed(
                                        const Duration(seconds: 1));
                                    if (ctx.mounted) Navigator.pop(ctx);
                                  } catch (_) {
                                    setSheetState(() =>
                                        currentState = WallpaperSetState.error);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSuccess
                                ? AetherColors.success
                                : AetherColors.electricCyan,
                            foregroundColor: AetherColors.charcoal,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AetherRadius.md),
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
                                        AetherColors.charcoal),
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
                    ],
                  ),
                ),
              ),
            );
          },
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
            // Full-screen video from file
            FullScreenFileVideoPlayer(filePath: widget.upload.filePath),

            // Top gradient
            Positioned(
              top: 0, left: 0, right: 0, height: 120,
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
                          border: Border.all(color: AetherColors.white10),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: AetherColors.white, size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: AetherSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.upload.name,
                            style: const TextStyle(
                              color: AetherColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'SpaceGrotesk',
                            ),
                          ),
                          const Text(
                            'YOUR UPLOAD',
                            style: TextStyle(
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
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
                          Icon(Icons.play_circle_outline_rounded,
                              size: 14, color: AetherColors.electricCyan),
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
              bottom: 0, left: 0, right: 0, height: 180,
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

            // Bottom action
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + AetherSpacing.lg,
              left: AetherSpacing.xl,
              right: AetherSpacing.xl,
              child: FadeTransition(
                opacity: _uiOpacity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _setAsWallpaper,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AetherColors.electricCyan,
                          foregroundColor: AetherColors.charcoal,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AetherRadius.md),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildInfoChip(
                          Icons.straighten_rounded,
                          '${widget.upload.sizeMb.toStringAsFixed(1)} MB',
                        ),
                        const SizedBox(width: AetherSpacing.md),
                        if (widget.upload.duration != null)
                          _buildInfoChip(
                            Icons.timer_rounded,
                            '${widget.upload.duration!.inSeconds}s',
                          ),
                        if (widget.upload.duration != null)
                          const SizedBox(width: AetherSpacing.md),
                        _buildInfoChip(Icons.upload_rounded, 'UPLOAD'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
}
