import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Security aesthetic: deep navy (dark) / light slate (light).
class ShiferTheme {
  /// Global brightness switch. Set before building the tree so all static
  /// color getters resolve consistently.
  static Brightness brightness = Brightness.dark;

  static bool get isDark => brightness == Brightness.dark;

  static Color get bg => isDark
      ? const Color(0xFF070B14)
      : const Color(0xFFF3F6FB);
  static Color get surface => isDark
      ? const Color(0xFF0E1626)
      : const Color(0xFFE9EEF6);
  static Color get card => isDark
      ? const Color(0xFF151F33)
      : const Color(0xFFFFFFFF);
  static Color get cardElevated => isDark
      ? const Color(0xFF1C2940)
      : const Color(0xFFF2F6FB);
  static Color get border => isDark
      ? const Color(0xFF2A3A55)
      : const Color(0xFFCBD6E4);
  static Color get primary => isDark
      ? const Color(0xFF3DDCBF)
      : const Color(0xFF0E8F7C);
  static Color get primaryDim => isDark
      ? const Color(0xFF1FA891)
      : const Color(0xFF0B6F61);
  static Color get accent => isDark
      ? const Color(0xFF7EB6FF)
      : const Color(0xFF2E6FD8);
  static Color get text => isDark
      ? const Color(0xFFE8EEF7)
      : const Color(0xFF16202E);
  static Color get muted => isDark
      ? const Color(0xFF8B9BB4)
      : const Color(0xFF5B6B82);
  static Color get danger => isDark
      ? const Color(0xFFFF6B7A)
      : const Color(0xFFD8344A);
  static Color get warning => isDark
      ? const Color(0xFFFFC857)
      : const Color(0xFFB97A00);
  static Color get success => isDark
      ? const Color(0xFF5CFFB0)
      : const Color(0xFF1FAF6A);

  static ThemeData forBrightness(Brightness mode) {
    final dark = mode == Brightness.dark;
    final baseText = GoogleFonts.outfitTextTheme(
      dark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    );
    final mono = GoogleFonts.ibmPlexMonoTextTheme(
      dark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: mode,
      scaffoldBackgroundColor: bg,
      colorScheme: dark
          ? ColorScheme.dark(
              surface: surface,
              primary: primary,
              secondary: accent,
              error: danger,
              onPrimary: const Color(0xFF04120F),
              onSurface: text,
              outline: border,
            )
          : ColorScheme.light(
              surface: surface,
              primary: primary,
              secondary: accent,
              error: danger,
              onPrimary: Colors.white,
              onSurface: text,
              outline: border,
            ),
      textTheme: baseText.apply(bodyColor: text, displayColor: text),
      primaryTextTheme: mono,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: text,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        hintStyle: TextStyle(color: muted),
        labelStyle: TextStyle(color: muted),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary, width: 1.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: dark ? const Color(0xFF04120F) : Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: card,
        selectedColor: primary.withValues(alpha: 0.18),
        labelStyle: TextStyle(color: text),
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: border),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withValues(alpha: 0.16),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? primary : muted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? primary : muted);
        }),
      ),
      dividerColor: border,
      dialogTheme: DialogThemeData(
        backgroundColor: cardElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  static ThemeData dark() => forBrightness(Brightness.dark);
  static ThemeData light() => forBrightness(Brightness.light);
}
