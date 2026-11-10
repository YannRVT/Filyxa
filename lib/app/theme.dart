import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

/// Couleurs du design system Filyxa (docs/DESIGN.md).
abstract final class FxColors {
  // Marque
  static const petrol = Color(0xFF064E49);
  static const petrolDark = Color(0xFF04332F);
  static const emerald = Color(0xFF0D9488); // graphismes uniquement, jamais du texte
  static const emeraldInk = Color(0xFF0F766E); // liens, focus, texte interactif
  static const mint = Color(0xFFA5E5D9);
  static const mintPale = Color(0xFFE3F4F0);
  static const cloud = Color(0xFFF1F7F6);

  // Neutres
  static const white = Color(0xFFFFFFFF);
  static const line = Color(0xFFD9E6E3);
  static const lineStrong = Color(0xFFB9CCC8);
  static const inkSoft = Color(0xFF556B68);
  static const ink = Color(0xFF1B2B29);

  // Sémantique
  static const success = Color(0xFF0F766E);
  static const successBg = Color(0xFFE3F4F0);
  static const warning = Color(0xFFB45309);
  static const warningBg = Color(0xFFFDF1E4);
  static const error = Color(0xFFB42318);
  static const errorBg = Color(0xFFFDECEA);
  static const info = Color(0xFF1D6FA3);
  static const infoBg = Color(0xFFE7F1F8);
  static const slate = Color(0xFF5B6B7A);
}

/// Espacements (base 8 px, demi-pas 4 px).
abstract final class FxSpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

/// Rayons d'arrondi.
abstract final class FxRadius {
  static const sm = 6.0;
  static const md = 10.0;
  static const lg = 12.0;
}

/// Points de rupture de la navigation adaptative.
abstract final class FxBreakpoints {
  /// À partir de cette largeur : barre latérale réduite aux icônes.
  static const tablet = 600.0;

  /// À partir de cette largeur : barre latérale complète avec le logo.
  static const desktop = 1024.0;
}

abstract final class FxTheme {
  /// Police d'étiquette technique (codes, compositions, codes à 6 chiffres).
  static TextStyle mono({double size = 14, FontWeight weight = FontWeight.w400, Color? color}) =>
      GoogleFonts.ibmPlexMono(fontSize: size, fontWeight: weight, color: color ?? FxColors.ink);

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: FxColors.petrol,
      onPrimary: FxColors.white,
      primaryContainer: FxColors.mintPale,
      onPrimaryContainer: FxColors.petrol,
      secondary: FxColors.emeraldInk,
      onSecondary: FxColors.white,
      secondaryContainer: FxColors.mintPale,
      onSecondaryContainer: FxColors.petrol,
      tertiary: FxColors.emerald,
      onTertiary: FxColors.white,
      error: FxColors.error,
      onError: FxColors.white,
      errorContainer: FxColors.errorBg,
      onErrorContainer: FxColors.error,
      surface: FxColors.white,
      onSurface: FxColors.ink,
      onSurfaceVariant: FxColors.inkSoft,
      surfaceContainerLowest: FxColors.white,
      surfaceContainerLow: FxColors.cloud,
      surfaceContainer: FxColors.cloud,
      surfaceContainerHigh: FxColors.mintPale,
      outline: FxColors.lineStrong,
      outlineVariant: FxColors.line,
    );

    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final body = GoogleFonts.sourceSans3TextTheme(base.textTheme).apply(
      bodyColor: FxColors.ink,
      displayColor: FxColors.petrol,
    );
    TextStyle? display(TextStyle? s) =>
        GoogleFonts.montserrat(textStyle: s, fontWeight: FontWeight.w700, color: FxColors.petrol);
    final textTheme = body.copyWith(
      displayLarge: display(body.displayLarge),
      displayMedium: display(body.displayMedium),
      displaySmall: display(body.displaySmall),
      headlineLarge: display(body.headlineLarge),
      headlineMedium: display(body.headlineMedium),
      headlineSmall: display(body.headlineSmall),
      titleLarge: display(body.titleLarge)?.copyWith(fontSize: 22),
      bodyMedium: body.bodyMedium?.copyWith(fontSize: 15),
      labelLarge: body.labelLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
    );

    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(FxRadius.md));
    const buttonPadding = EdgeInsets.symmetric(horizontal: 18, vertical: 14);
    OutlineInputBorder field(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(FxRadius.sm),
          borderSide: BorderSide(color: c, width: w),
        );

    return base.copyWith(
      scaffoldBackgroundColor: FxColors.cloud,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: FxColors.cloud,
        foregroundColor: FxColors.petrol,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: FxColors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FxRadius.lg),
          side: const BorderSide(color: FxColors.line),
        ),
      ),
      dividerTheme: const DividerThemeData(color: FxColors.line, space: 1, thickness: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: FxColors.petrol,
          foregroundColor: FxColors.white,
          disabledBackgroundColor: FxColors.line,
          shape: buttonShape,
          padding: buttonPadding,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: FxColors.emeraldInk,
          side: const BorderSide(color: FxColors.lineStrong),
          shape: buttonShape,
          padding: buttonPadding,
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: FxColors.emeraldInk,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FxColors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        labelStyle: const TextStyle(color: FxColors.inkSoft),
        helperStyle: const TextStyle(color: FxColors.inkSoft, fontSize: 13),
        border: field(FxColors.lineStrong),
        enabledBorder: field(FxColors.lineStrong),
        focusedBorder: field(FxColors.emeraldInk, 2),
        errorBorder: field(FxColors.error),
        focusedErrorBorder: field(FxColors.error, 2),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: FxColors.petrol,
        contentTextStyle: TextStyle(color: FxColors.white),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: FxColors.emeraldInk),
    );
  }
}
