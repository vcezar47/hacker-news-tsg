import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

/// "Soft cards" look: lavender-white page, white rounded cards, indigo accent, teal for status.
/// The dark variant keeps the same hues on a deep navy base.
ThemeData appTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme =
      ColorScheme.fromSeed(
        seedColor: const Color(0xFF4F46E5),
        brightness: brightness,
      ).copyWith(
        surface: dark ? const Color(0xFF12102B) : const Color(0xFFF4F3FF),
        surfaceContainer: dark ? const Color(0xFF1E1B4B) : Colors.white,
        primary: dark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5),
        onPrimary: dark ? const Color(0xFF1E1B4B) : Colors.white,
        primaryContainer: dark
            ? const Color(0xFF312E81)
            : const Color(0xFFE0E7FF),
        onPrimaryContainer: dark
            ? const Color(0xFFC7D2FE)
            : const Color(0xFF3730A3),
        tertiaryContainer: dark
            ? const Color(0xFF134E4A)
            : const Color(0xFFCCFBF1),
        onTertiaryContainer: dark
            ? const Color(0xFF99F6E4)
            : const Color(0xFF0F766E),
        onSurface: dark ? const Color(0xFFEEF0FF) : const Color(0xFF1E1B4B),
        onSurfaceVariant: dark
            ? const Color(0xFFA5A8C6)
            : const Color(0xFF5B5F7A),
        outlineVariant: dark
            ? const Color(0xFF3B3870)
            : const Color(0xFFD9DBF2),
        inverseSurface: dark
            ? const Color(0xFFEEF0FF)
            : const Color(0xFF1E1B4B),
        onInverseSurface: dark ? const Color(0xFF1E1B4B) : Colors.white,
      );

  // Sora for headings, DM Sans for everything else. The fonts download on first use
  // (then cache); until then the phone's default font is shown.
  final base = ThemeData(brightness: brightness, useMaterial3: true).textTheme;
  final body = GoogleFonts.dmSansTextTheme(base);
  TextStyle? sora(TextStyle? style, double size) => GoogleFonts.sora(
    textStyle: style,
    fontSize: size,
    fontWeight: FontWeight.w500,
  );
  final textTheme = body
      .copyWith(
        headlineSmall: sora(body.headlineSmall, 24),
        titleLarge: sora(body.titleLarge, 20),
        titleMedium: sora(body.titleMedium, 16),
        titleSmall: sora(body.titleSmall, 14),
      )
      .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    // Screens fade and drift in instead of the default slide.
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {TargetPlatform.android: FadeForwardsPageTransitionsBuilder()},
    ),
  );
}
