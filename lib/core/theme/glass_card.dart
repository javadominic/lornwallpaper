import 'dart:ui';
import 'package:flutter/material.dart';
import 'aether_theme.dart';

/// ─── Glassmorphism Card ──────────────────────────────────────────────────────
/// Frosted glass effect using BackdropFilter with blur and subtle borders.
/// ─────────────────────────────────────────────────────────────────────────────

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double blur;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = AetherRadius.lg,
    this.padding,
    this.blur = 20.0,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor ?? AetherColors.glassBackground,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ?? AetherColors.glassBorder,
                width: 1.0,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AetherColors.glassHighlight,
                  AetherColors.glassBackground,
                ],
              ),
            ),
            padding: padding ??
                const EdgeInsets.all(AetherSpacing.md),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A glass morphism container with a subtle cyan highlight accent.
class GlassAccentCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool showGlow;

  const GlassAccentCard({
    super.key,
    required this.child,
    this.borderRadius = AetherRadius.lg,
    this.padding,
    this.showGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: showGlow ? AetherShadows.subtleCyanGlow : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AetherColors.white10,
                  AetherColors.white05,
                ],
              ),
              border: Border.all(
                color: AetherColors.glassBorder,
                width: 0.5,
              ),
            ),
            padding: padding ??
                const EdgeInsets.all(AetherSpacing.md),
            child: child,
          ),
        ),
      ),
    );
  }
}
