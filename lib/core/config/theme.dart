import 'package:flutter/material.dart';

import 'tokens.dart';

/// Material тема HabitFlow. Тонкая обёртка над дизайн-токенами:
/// поднимает HFColors через ThemeExtension, чтобы виджеты обращались
/// к ним через `HFColors.of(context)`.
class AppTheme {
  static ThemeData light({Color? accentOverride}) {
    final base = HFColors.light;
    final colors =
        accentOverride == null ? base : base.copyWith(accent: accentOverride);
    return _build(colors, Brightness.light);
  }

  static ThemeData dark({Color? accentOverride}) {
    final base = HFColors.dark;
    final colors =
        accentOverride == null ? base : base.copyWith(accent: accentOverride);
    return _build(colors, Brightness.dark);
  }

  static ThemeData _build(HFColors colors, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: colors.accent,
      onPrimary: Colors.white,
      secondary: colors.accent,
      onSecondary: Colors.white,
      error: colors.danger,
      onError: Colors.white,
      surface: colors.bgPrimary,
      onSurface: colors.textPrimary,
      surfaceContainerHighest: colors.bgTertiary,
      outline: colors.border,
    );

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.bgSecondary,
      canvasColor: colors.bgSecondary,
      dividerColor: colors.border,
      splashFactory: InkRipple.splashFactory,
      textTheme: TextTheme(
        displayLarge: HFTokens.tsDisplay.copyWith(color: colors.textPrimary),
        titleLarge: HFTokens.tsTitle.copyWith(color: colors.textPrimary),
        titleMedium: HFTokens.tsSubheading.copyWith(color: colors.textPrimary),
        bodyLarge: HFTokens.tsBody.copyWith(color: colors.textPrimary),
        bodyMedium: HFTokens.tsSecondary.copyWith(color: colors.textSecondary),
        labelMedium: HFTokens.tsLabel.copyWith(color: colors.textTertiary),
      ),
      extensions: [colors],
    );
  }
}
