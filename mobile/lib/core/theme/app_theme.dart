import 'package:material_ui/material_ui.dart';

import '../models/enums.dart';

/// Material 3 theme from a single brand color (docs/PLAN.md section 9).
abstract final class AppTheme {
  /// Brand color. Placeholder until the owner picks one (see DECISIONS).
  static const brandColor = Color(0xFFD9480F);

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: brandColor,
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: scheme,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      ),
    );
  }
}

/// Tier badge colors: BASIC grey, PLUS blue, PREMIUM gold (section 9).
abstract final class TierColors {
  static Color background(Tier tier) => switch (tier) {
    Tier.basic => const Color(0xFF616161),
    Tier.plus => const Color(0xFF1565C0),
    Tier.premium => const Color(0xFFC9A227),
  };

  static Color foreground(Tier tier) => switch (tier) {
    Tier.basic || Tier.plus => const Color(0xFFFFFFFF),
    Tier.premium => const Color(0xFF1F1A00),
  };
}
