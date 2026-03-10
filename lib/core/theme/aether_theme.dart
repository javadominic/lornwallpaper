import 'package:flutter/material.dart';

/// ─── Aether Design System ───────────────────────────────────────────────────
/// Premium Minimalist palette: Charcoal + Electric Cyan
/// ─────────────────────────────────────────────────────────────────────────────

class AetherColors {
  AetherColors._();

  // ── Primary palette ──
  static const Color charcoal = Color(0xFF121212);
  static const Color charcoalLight = Color(0xFF1E1E1E);
  static const Color charcoalSurface = Color(0xFF2A2A2A);
  static const Color electricCyan = Color(0xFF00FFFF);
  static const Color electricCyanDim = Color(0xFF00B8B8);
  static const Color electricCyanGlow = Color(0x4000FFFF);

  // ── Neutral shades ──
  static const Color white = Color(0xFFFFFFFF);
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color white50 = Color(0x80FFFFFF);
  static const Color white30 = Color(0x4DFFFFFF);
  static const Color white10 = Color(0x1AFFFFFF);
  static const Color white05 = Color(0x0DFFFFFF);

  // ── Glassmorphism ──
  static const Color glassBackground = Color(0x1AFFFFFF); // 10% white
  static const Color glassBorder = Color(0x33FFFFFF);      // 20% white
  static const Color glassHighlight = Color(0x0DFFFFFF);   // 5% white

  // ── Semantic ──
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFD600);
  static const Color error = Color(0xFFFF5252);
}

class AetherSpacing {
  AetherSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}

class AetherRadius {
  AetherRadius._();

  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double pill = 100.0;
}

class AetherShadows {
  AetherShadows._();

  static List<BoxShadow> get cyanGlow => [
        BoxShadow(
          color: AetherColors.electricCyanGlow,
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ];

  static List<BoxShadow> get subtleCyanGlow => [
        BoxShadow(
          color: AetherColors.electricCyanGlow.withOpacity(0.15),
          blurRadius: 12,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get elevation => [
        const BoxShadow(
          color: Color(0x40000000),
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ];
}

class AetherTheme {
  AetherTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AetherColors.charcoal,
      colorScheme: const ColorScheme.dark(
        primary: AetherColors.electricCyan,
        onPrimary: AetherColors.charcoal,
        secondary: AetherColors.electricCyanDim,
        onSecondary: AetherColors.charcoal,
        surface: AetherColors.charcoalLight,
        onSurface: AetherColors.white,
        error: AetherColors.error,
        onError: AetherColors.white,
      ),
      fontFamily: 'SpaceGrotesk',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AetherColors.white,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AetherColors.white,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AetherColors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AetherColors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AetherColors.white70,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AetherColors.white70,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AetherColors.white50,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AetherColors.white30,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AetherColors.electricCyan,
          letterSpacing: 1.2,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AetherColors.white,
          fontFamily: 'SpaceGrotesk',
        ),
        iconTheme: IconThemeData(color: AetherColors.white),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBarrierColor: Color(0x80000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AetherRadius.xl),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AetherColors.electricCyan,
          foregroundColor: AetherColors.charcoal,
          padding: const EdgeInsets.symmetric(
            horizontal: AetherSpacing.lg,
            vertical: AetherSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AetherRadius.md),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'SpaceGrotesk',
            letterSpacing: 0.5,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AetherColors.electricCyan;
          }
          return AetherColors.white50;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AetherColors.electricCyanGlow;
          }
          return AetherColors.white10;
        }),
      ),
      iconTheme: const IconThemeData(
        color: AetherColors.electricCyan,
        size: 24,
      ),
      dividerTheme: const DividerThemeData(
        color: AetherColors.white10,
        thickness: 1,
      ),
    );
  }
}
