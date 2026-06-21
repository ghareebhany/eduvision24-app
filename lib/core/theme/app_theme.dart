import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ══════════════════════════════════════════════════════════════════════════
  // Brand Palette — EduVision Explorer Theme
  // مستوحاة من لوجو المستكشف والخريطة
  //
  //  --dry-sage:      #C9CBA3  ← أخضر مائل للرمادي (خلفيات، بطاقات)
  //  --soft-peach:    #FFE1A8  ← أصفر دافئ (highlights، accents)
  //  --vibrant-coral: #E26D5C  ← مرجاني حيوي (أزرار، CTAs)
  //  --wine-plum:     #723D46  ← خمري (headers، text بارز)
  //  --deep-mocha:    #472D30  ← موكا عميق (headers داكنة، splash)
  // ══════════════════════════════════════════════════════════════════════════

  // ── Primary — Deep Mocha & Wine Plum ──────────────────────────────────────
  static const Color mocha900     = Color(0xFF2A1A1C); // أعمق — splash bg
  static const Color mocha800     = Color(0xFF3A2225); // headers داكنة
  static const Color mocha700     = Color(0xFF472D30); // deep-mocha ✦
  static const Color mocha600     = Color(0xFF5C3A3E);
  static const Color mocha500     = Color(0xFF723D46); // wine-plum ✦
  static const Color mocha400     = Color(0xFF8E5560);
  static const Color mocha200     = Color(0xFFD4A8AE); // borders
  static const Color mocha100     = Color(0xFFF2E4E6); // light containers
  static const Color mocha50      = Color(0xFFFAF2F3); // lightest bg
  static const Color softPeach     = Color(0xFFFFE1A8);

  // ── Accent — Coral & Peach ────────────────────────────────────────────────
  static const Color coral600     = Color(0xFFC8503F); // coral داكن للـ dark mode
  static const Color coral500     = Color(0xFFE26D5C); // vibrant-coral ✦ (CTAs)
  static const Color coral400     = Color(0xFFE88577);
  static const Color coral200     = Color(0xFFF5C4BC);
  static const Color coral100     = Color(0xFFFDEBE8);
  static const Color coral50      = Color(0xFFFFF5F4);

  static const Color peach500     = Color(0xFFFFE1A8); // soft-peach ✦ (highlights)
  static const Color peach400     = Color(0xFFFFECBF);
  static const Color peach200     = Color(0xFFFFF4D9);
  static const Color peach100     = Color(0xFFFFFAEE);

  // ── Neutral — Dry Sage ────────────────────────────────────────────────────
  static const Color sage500      = Color(0xFFC9CBA3); // dry-sage ✦ (cards، dividers)
  static const Color sage400      = Color(0xFFD6D8B5);
  static const Color sage300      = Color(0xFFE3E4C9);
  static const Color sage200      = Color(0xFFEEEFDF);
  static const Color sage100      = Color(0xFFF5F6EE); // scaffold
  static const Color sage50       = Color(0xFFFAFAF4);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textDark     = Color(0xFF2A1A1C); // على خلفيات فاتحة
  static const Color textMid      = Color(0xFF5C3A3E); // secondary text
  static const Color textMuted    = Color(0xFF8E7174); // muted/hints

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color success      = Color(0xFFE26D5C);
  static const Color successLight = Color(0xFFFDEBE8);
  static const Color warning      = Color(0xFFB07D2B);
  static const Color warningLight = Color(0xFFFFF3CD);
  static const Color error        = Color(0xFFB83232);
  static const Color errorLight   = Color(0xFFFDE8E8);

  // ── Backward-compat aliases (لا تكسر الشاشات القديمة) ─────────────────────
  static const Color navy900      = mocha900;
  static const Color navy800      = mocha800;
  static const Color navy700      = mocha700;
  static const Color navy600      = mocha500; // wine-plum = "primary"
  static const Color navy500      = mocha600;
  static const Color navy400      = mocha400;
  static const Color navy200      = mocha200;
  static const Color navy100      = mocha100;
  static const Color navy50       = mocha50;
  static const Color sky500       = coral500; // coral = "accent"
  static const Color sky400       = coral400;
  static const Color sky300       = coral200;
  static const Color sky100       = coral100;
  static const Color sky50        = coral50;
  static const Color slate900     = textDark;
  static const Color slate700     = textMid;
  static const Color slate500     = textMuted;
  static const Color slate300     = sage500;
  static const Color slate200     = sage300;
  static const Color slate100     = sage100;
  static const Color slate50      = sage50;

  // ── Cairo TextTheme ───────────────────────────────────────────────────────
  // ════════════════════════════════════════════════════════════════════════
  //  Design Tokens — مقاييس موحّدة (إضافية بالكامل، لا تكسر أي شيء قائم)
  // ════════════════════════════════════════════════════════════════════════

  // ── Spacing scale (8-pt grid) ──
  static const double space2  = 2;
  static const double space4  = 4;
  static const double space8  = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;

  // ── Corner radii ──
  static const double radiusSm   = 12;
  static const double radiusMd   = 16;
  static const double radiusLg   = 20;
  static const double radiusXl   = 28;
  static const double radiusPill = 999;

  static const BorderRadius brSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius brMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius brLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius brXl = BorderRadius.all(Radius.circular(radiusXl));

  // ── Elevation / shadows (طبقات ناعمة بلون العلامة) ──
  static List<BoxShadow> get shadowSm => [
        BoxShadow(color: mocha900.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
      ];
  static List<BoxShadow> get shadowMd => [
        BoxShadow(color: mocha900.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 6)),
        BoxShadow(color: mocha900.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2)),
      ];
  static List<BoxShadow> get shadowLg => [
        BoxShadow(color: mocha900.withValues(alpha: 0.10), blurRadius: 28, offset: const Offset(0, 12)),
        BoxShadow(color: mocha900.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 4)),
      ];
  static List<BoxShadow> coloredShadow(Color c, {double alpha = 0.35}) => [
        BoxShadow(color: c.withValues(alpha: alpha), blurRadius: 20, offset: const Offset(0, 10)),
      ];

  // ── Motion ──
  static const Duration motionFast = Duration(milliseconds: 180);
  static const Duration motionMed  = Duration(milliseconds: 280);
  static const Duration motionSlow = Duration(milliseconds: 450);
  static const Curve    easeOutExpo = Curves.easeOutCubic;

  // ── Premium TextTheme: Tajawal للعناوين + Cairo للنصوص ──
  static TextTheme get _cairoTextTheme {
    final base = GoogleFonts.cairoTextTheme();
    return base.copyWith(
      displayLarge:   GoogleFonts.tajawal(textStyle: base.displayLarge,   fontWeight: FontWeight.w800, height: 1.15, letterSpacing: -0.5),
      displayMedium:  GoogleFonts.tajawal(textStyle: base.displayMedium,  fontWeight: FontWeight.w800, height: 1.18, letterSpacing: -0.5),
      displaySmall:   GoogleFonts.tajawal(textStyle: base.displaySmall,   fontWeight: FontWeight.w700, height: 1.20),
      headlineLarge:  GoogleFonts.tajawal(textStyle: base.headlineLarge,  fontWeight: FontWeight.w700, height: 1.20),
      headlineMedium: GoogleFonts.tajawal(textStyle: base.headlineMedium, fontWeight: FontWeight.w700, height: 1.25),
      headlineSmall:  GoogleFonts.tajawal(textStyle: base.headlineSmall,  fontWeight: FontWeight.w700, height: 1.30),
      titleLarge:     GoogleFonts.tajawal(textStyle: base.titleLarge,     fontWeight: FontWeight.w700, height: 1.30),
      titleMedium:    GoogleFonts.cairo(textStyle: base.titleMedium,      fontWeight: FontWeight.w600, height: 1.40, letterSpacing: 0.1),
      titleSmall:     GoogleFonts.cairo(textStyle: base.titleSmall,       fontWeight: FontWeight.w600, height: 1.40),
      bodyLarge:      GoogleFonts.cairo(textStyle: base.bodyLarge,        height: 1.60, letterSpacing: 0.1),
      bodyMedium:     GoogleFonts.cairo(textStyle: base.bodyMedium,       height: 1.60, letterSpacing: 0.1),
      bodySmall:      GoogleFonts.cairo(textStyle: base.bodySmall,        height: 1.50),
      labelLarge:     GoogleFonts.cairo(textStyle: base.labelLarge,       fontWeight: FontWeight.w600, letterSpacing: 0.2),
      labelMedium:    GoogleFonts.cairo(textStyle: base.labelMedium,      fontWeight: FontWeight.w600),
      labelSmall:     GoogleFonts.cairo(textStyle: base.labelSmall,       fontWeight: FontWeight.w600),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Light Theme
  // ══════════════════════════════════════════════════════════════════════════
  static ThemeData light() {
    final cs = ColorScheme(
      brightness:               Brightness.light,
      primary:                  mocha500,       // wine-plum
      onPrimary:                Colors.white,
      primaryContainer:         mocha100,
      onPrimaryContainer:       mocha800,
      secondary:                coral500,       // vibrant-coral
      onSecondary:              Colors.white,
      secondaryContainer:       coral100,
      onSecondaryContainer:     mocha700,
      tertiary:                 mocha600,
      onTertiary:               Colors.white,
      tertiaryContainer:        peach100,
      onTertiaryContainer:      mocha700,
      error:                    error,
      onError:                  Colors.white,
      errorContainer:           errorLight,
      onErrorContainer:         const Color(0xFF7F1D1D),
      surface:                  Colors.white,
      onSurface:                textDark,
      surfaceContainerHighest:  sage100,
      outline:                  sage500,
      outlineVariant:           sage300,
      shadow:                   Colors.black,
      scrim:                    Colors.black,
      inverseSurface:           mocha800,
      onInverseSurface:         sage50,
      inversePrimary:           coral400,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: sage100,
      textTheme: _cairoTextTheme.apply(
          bodyColor: textDark, displayColor: textDark),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: mocha700,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.tajawal(
            fontSize: 19, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.2),
        iconTheme: const IconThemeData(color: Colors.white),
        shadowColor: Colors.black26,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shadowColor: mocha500.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: BorderSide(color: sage200),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: coral500,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
          minimumSize: const Size(64, 52),
          elevation: 3,
          shadowColor: coral500.withValues(alpha: 0.45),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: coral500,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
          minimumSize: const Size(64, 52),
          elevation: 3,
          shadowColor: coral500.withValues(alpha: 0.45),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: mocha500,
          side: const BorderSide(color: mocha500, width: 1.5),
          textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(64, 50),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: coral500,
          textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 14),
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: sage100,
        hintStyle: GoogleFonts.cairo(color: textMuted, fontSize: 14),
        labelStyle: GoogleFonts.cairo(color: textMuted, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: sage400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: sage400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: mocha500, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: mocha500,
        unselectedItemColor: textMuted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: mocha100,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: mocha500);
          }
          return IconThemeData(color: textMuted);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.cairo(
                color: mocha500, fontSize: 11, fontWeight: FontWeight.bold);
          }
          return GoogleFonts.cairo(color: textMuted, fontSize: 11);
        }),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: sage100,
        selectedColor: mocha100,
        labelStyle: GoogleFonts.cairo(fontSize: 13, color: textMid),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: sage400),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      dividerTheme: const DividerThemeData(color: sage300, thickness: 1, space: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: mocha800,
        contentTextStyle: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: coral500,
        linearTrackColor: sage300,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: mocha500,
        unselectedLabelColor: textMuted,
        indicatorColor: coral500,
        labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14),
        unselectedLabelStyle: GoogleFonts.cairo(fontSize: 14),
        dividerColor: sage300,
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Dark Theme
  // ══════════════════════════════════════════════════════════════════════════
  static ThemeData dark() {
    const darkBg       = Color(0xFF1C1214);
    const darkSurface  = Color(0xFF2A1A1C);
    const darkCard     = Color(0xFF3A2225);
    const darkBorder   = Color(0xFF5C3A3E);
    const darkText     = Color(0xFFF5EEE8);
    const darkMuted    = Color(0xFFB89EA0);

    final cs = ColorScheme(
      brightness:               Brightness.dark,
      primary:                  coral500,
      onPrimary:                Colors.white,
      primaryContainer:         const Color(0xFF5C1F18),
      onPrimaryContainer:       coral200,
      secondary:                peach500,
      onSecondary:              mocha800,
      secondaryContainer:       const Color(0xFF4A3010),
      onSecondaryContainer:     peach400,
      tertiary:                 coral400,
      onTertiary:               mocha900,
      tertiaryContainer:        darkCard,
      onTertiaryContainer:      darkText,
      error:                    const Color(0xFFF87171),
      onError:                  darkBg,
      errorContainer:           const Color(0xFF4A1515),
      onErrorContainer:         const Color(0xFFFCA5A5),
      surface:                  darkSurface,
      onSurface:                darkText,
      surfaceContainerHighest:  darkCard,
      outline:                  darkBorder,
      outlineVariant:           const Color(0xFF4A2E30),
      shadow:                   Colors.black,
      scrim:                    Colors.black,
      inverseSurface:           sage100,
      onInverseSurface:         textDark,
      inversePrimary:           mocha500,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: darkBg,
      textTheme: _cairoTextTheme.apply(
          bodyColor: darkText, displayColor: darkText),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: darkSurface,
        foregroundColor: darkText,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.cairo(
            fontSize: 17, fontWeight: FontWeight.bold, color: darkText),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: darkCard,
        shadowColor: Colors.black.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: darkBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: coral500,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
          minimumSize: const Size(64, 52),
          elevation: 3,
          shadowColor: coral500.withValues(alpha: 0.45),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: coral500,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
          minimumSize: const Size(64, 52),
          elevation: 3,
          shadowColor: coral500.withValues(alpha: 0.45),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: coral500,
          side: const BorderSide(color: coral500, width: 1.5),
          textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(64, 50),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: coral500,
          textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 14),
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        hintStyle: GoogleFonts.cairo(color: darkMuted, fontSize: 14),
        labelStyle: GoogleFonts.cairo(color: darkMuted, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: coral500, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkSurface,
        indicatorColor: const Color(0xFF4A1A1E),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: coral500);
          }
          return const IconThemeData(color: darkMuted);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.cairo(
                color: coral500, fontSize: 11, fontWeight: FontWeight.bold);
          }
          return GoogleFonts.cairo(color: darkMuted, fontSize: 11);
        }),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(color: darkBorder, thickness: 1, space: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkCard,
        contentTextStyle: GoogleFonts.cairo(color: darkText, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: coral500,
        linearTrackColor: darkBorder,
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Gradient Helpers
  // ══════════════════════════════════════════════════════════════════════════

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [mocha900, mocha700, mocha500],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [coral500, mocha500],
    begin: Alignment.centerRight,
    end: Alignment.centerLeft,
  );

  // CTA مرجاني فاخر (للأزرار الرئيسية البارزة)
  static const LinearGradient ctaGradient = LinearGradient(
    colors: [coral400, coral600],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  // توهّج خوخي للعناصر المميّزة (شارات، أسعار)
  static const LinearGradient peachGlow = LinearGradient(
    colors: [peach500, coral400],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // لمعان خفيف لخلفيات البطاقات الفاخرة
  static LinearGradient cardSheen(bool isDark) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? const [Color(0xFF3A2225), Color(0xFF2A1A1C)]
            : [Colors.white, sage50],
      );

  static const LinearGradient progressGradient = LinearGradient(
    colors: [coral500, mocha500],
    begin: Alignment.centerRight,
    end: Alignment.centerLeft,
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [mocha900, mocha800, mocha700],
    stops: [0.0, 0.5, 1.0],
  );

  // كل فئة لها gradient مستوحى من لوحة الألوان
  static const List<List<Color>> categoryGradients = [
    [mocha700, mocha500],   // default — mocha/wine
    [Color(0xFF4A3010), Color(0xFFB07D2B)], // history — amber
    [Color(0xFF5C3A3E), Color(0xFF9B4F5A)], // science — plum
    [coral600, coral500],   // language — coral
    [Color(0xFF2A3045), Color(0xFF4A5578)], // math — blue-gray
    [Color(0xFF3D2545), Color(0xFF7A4A8E)], // arts — purple
  ];
}
