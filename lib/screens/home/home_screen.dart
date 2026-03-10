import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme/aether_theme.dart';
import '../../data/wallpaper_catalog.dart';
import '../../models/wallpaper_model.dart';
import '../../services/asset_loading_service.dart';
import '../../services/upload_wallpaper_service.dart';
import '../../widgets/grid/wallpaper_grid_card.dart';
import '../../widgets/shimmer_loading.dart';
import '../viewer/upload_viewer_screen.dart';
import '../viewer/wallpaper_viewer_screen.dart';

/// ─── Homepage Screen ────────────────────────────────────────────────────────
/// Sleek glassmorphism grid showcasing 3D wallpaper previews.
/// Features:
///   • Category filter chips
///   • 2-column grid with live 3D previews
///   • Shimmer loading for initial download
///   • Pull-to-refresh support
/// ─────────────────────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  WallpaperCategory? _selectedCategory;
  bool _isLoading = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  List<WallpaperModel> get _filteredWallpapers {
    if (_selectedCategory == null) {
      return WallpaperCatalog.wallpapers;
    }
    return WallpaperCatalog.wallpapers
        .where((w) => w.category == _selectedCategory)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _initializeAssets();
  }

  Future<void> _initializeAssets() async {
    // Simulate progressive asset loading for demo
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() => _isLoading = false);
      _fadeController.forward();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _openViewer(WallpaperModel wallpaper) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) {
          return WallpaperViewerScreen(wallpaper: wallpaper);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AetherColors.charcoal,
      floatingActionButton: _buildUploadFab(),
      body: Stack(
        children: [
          // Background gradient
          _buildBackgroundGradient(),

          // Main content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Top spacing
              SliverToBoxAdapter(
                child: SizedBox(height: topPadding + AetherSpacing.md),
              ),

              // Header
              SliverToBoxAdapter(child: _buildHeader()),

              // Category chips
              SliverToBoxAdapter(child: _buildCategoryChips()),

              // Your Uploads section
              SliverToBoxAdapter(child: _buildUploadsSection()),

              // Spacer
              const SliverToBoxAdapter(
                child: SizedBox(height: AetherSpacing.md),
              ),

              // Grid
              _isLoading
                  ? SliverToBoxAdapter(child: _buildShimmerGrid())
                  : _buildWallpaperGrid(),

              // Bottom spacing
              const SliverToBoxAdapter(
                child: SizedBox(height: AetherSpacing.xxxl),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUploadFab() {
    return FloatingActionButton(
      onPressed: _handleUpload,
      backgroundColor: AetherColors.electricCyan,
      foregroundColor: AetherColors.charcoal,
      elevation: 4,
      child: const Icon(Icons.add_rounded, size: 28),
    );
  }

  Future<void> _handleUpload() async {
    final uploadService = context.read<UploadWallpaperService>();
    final result = await uploadService.pickAndValidate();

    if (!mounted) return;

    if (!result.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Upload failed'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    // Open the upload viewer directly
    final uploads = uploadService.uploads;
    if (uploads.isNotEmpty) {
      _openUploadViewer(uploads.first);
    }
  }

  void _openUploadViewer(UploadedWallpaper upload) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) {
          return UploadViewerScreen(upload: upload);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: child,
          );
        },
      ),
    );
  }

  Widget _buildUploadsSection() {
    final uploadService = context.watch<UploadWallpaperService>();
    final uploads = uploadService.uploads;

    if (uploads.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AetherSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AetherSpacing.lg),
            child: Text(
              'YOUR UPLOADS',
              style: TextStyle(
                color: AetherColors.electricCyanDim,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
                fontFamily: 'SpaceGrotesk',
              ),
            ),
          ),
          const SizedBox(height: AetherSpacing.sm),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AetherSpacing.lg,
              ),
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AetherSpacing.sm),
              itemCount: uploads.length,
              itemBuilder: (context, index) {
                final upload = uploads[index];
                return _buildUploadCard(upload, uploadService);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCard(
      UploadedWallpaper upload, UploadWallpaperService service) {
    return GestureDetector(
      onTap: () => _openUploadViewer(upload),
      onLongPress: () => _showDeleteDialog(upload, service),
      child: Container(
        width: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AetherRadius.md),
          border: Border.all(
            color: AetherColors.electricCyan.withOpacity(0.2),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video thumbnail preview
            _UploadThumbnail(filePath: upload.filePath),

            // Gradient overlay
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AetherColors.charcoal.withOpacity(0.9),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      upload.name,
                      style: const TextStyle(
                        color: AetherColors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'SpaceGrotesk',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${upload.sizeMb.toStringAsFixed(1)} MB',
                      style: const TextStyle(
                        color: AetherColors.white30,
                        fontSize: 9,
                        fontFamily: 'SpaceGrotesk',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Upload badge
            Positioned(
              top: 6, right: 6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AetherColors.electricCyan.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.upload_rounded,
                  size: 10,
                  color: AetherColors.electricCyan,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(
      UploadedWallpaper upload, UploadWallpaperService service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AetherColors.charcoalLight,
        title: const Text('Delete Upload',
            style: TextStyle(color: AetherColors.white)),
        content: Text(
          'Remove "${upload.name}"?',
          style: const TextStyle(color: AetherColors.white50),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              service.deleteUpload(upload);
              Navigator.pop(ctx);
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGradient() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.0, -0.5),
            radius: 1.2,
            colors: [
              AetherColors.electricCyan.withOpacity(0.03),
              AetherColors.charcoal,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AetherSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Logo/Icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      AetherColors.electricCyan,
                      AetherColors.electricCyanDim,
                    ],
                  ),
                  boxShadow: AetherShadows.subtleCyanGlow,
                ),
                child: const Icon(
                  Icons.diamond_rounded,
                  color: AetherColors.charcoal,
                  size: 20,
                ),
              ),
              const SizedBox(width: AetherSpacing.sm),
              const Text(
                'LORN',
                style: TextStyle(
                  color: AetherColors.electricCyan,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4.0,
                  fontFamily: 'SpaceGrotesk',
                ),
              ),
              const Spacer(),
              // Settings icon
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.tune_rounded,
                  color: AetherColors.white50,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: AetherSpacing.lg),
          const Text(
            'Live\nWallpapers',
            style: TextStyle(
              color: AetherColors.white,
              fontSize: 36,
              fontWeight: FontWeight.w700,
              height: 1.1,
              fontFamily: 'SpaceGrotesk',
            ),
          ),
          const SizedBox(height: AetherSpacing.xs),
          Text(
            '${WallpaperCatalog.wallpapers.length} premium 3D wallpapers',
            style: const TextStyle(
              color: AetherColors.white30,
              fontSize: 14,
              fontFamily: 'SpaceGrotesk',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = [
      null, // "All"
      ...WallpaperCategory.values,
    ];

    return Padding(
      padding: const EdgeInsets.only(top: AetherSpacing.lg),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: AetherSpacing.lg,
          ),
          separatorBuilder: (_, __) =>
              const SizedBox(width: AetherSpacing.sm),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = _selectedCategory == category;
            final label = category == null
                ? 'All'
                : category.name[0].toUpperCase() +
                    category.name.substring(1);

            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AetherColors.electricCyan
                      : AetherColors.white05,
                  borderRadius: BorderRadius.circular(AetherRadius.pill),
                  border: Border.all(
                    color: isSelected
                        ? AetherColors.electricCyan
                        : AetherColors.white10,
                    width: 1,
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? AetherColors.charcoal
                        : AetherColors.white50,
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontFamily: 'SpaceGrotesk',
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return const SizedBox(
      height: 500,
      child: WallpaperGridShimmer(itemCount: 6),
    );
  }

  Widget _buildWallpaperGrid() {
    final wallpapers = _filteredWallpapers;
    final assetService = context.watch<AssetLoadingService>();

    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: AetherSpacing.md,
      ),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AetherSpacing.md,
          crossAxisSpacing: AetherSpacing.md,
          childAspectRatio: 0.72,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final wallpaper = wallpapers[index];
            final progress = assetService.getProgress(wallpaper.id);

            return FadeTransition(
              opacity: _fadeAnimation,
              child: WallpaperGridCard(
                wallpaper: wallpaper,
                assetProgress: progress,
                onTap: () => _openViewer(wallpaper),
              ),
            );
          },
          childCount: wallpapers.length,
        ),
      ),
    );
  }
}

/// Small video thumbnail for upload cards — plays first frame only.
class _UploadThumbnail extends StatefulWidget {
  final String filePath;
  const _UploadThumbnail({required this.filePath});

  @override
  State<_UploadThumbnail> createState() => _UploadThumbnailState();
}

class _UploadThumbnailState extends State<_UploadThumbnail> {
  late dynamic _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      final file = File(widget.filePath);
      final controller = VideoPlayerController.file(file);
      _controller = controller;
      await controller.initialize();
      controller.setVolume(0);
      // Show first frame but don't play
      controller.seekTo(Duration.zero);
      if (mounted) setState(() => _initialized = true);
    } catch (_) {}
  }

  @override
  void dispose() {
    try {
      (_controller as VideoPlayerController).dispose();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Container(
        color: AetherColors.charcoalLight,
        child: const Center(
          child: Icon(
            Icons.videocam_rounded,
            color: AetherColors.white30,
            size: 24,
          ),
        ),
      );
    }

    final vc = _controller as VideoPlayerController;
    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: vc.value.size.width,
        height: vc.value.size.height,
        child: VideoPlayer(vc),
      ),
    );
  }
}

