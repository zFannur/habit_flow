import 'package:flutter/material.dart';

/// Дизайн-токены HabitFlow (см. docs/design/design-system.html).
/// Копируются 1:1, не подменяй "более красивыми" значениями.
class HFTokens {
  HFTokens._();

  // ────────────────────────── COLORS ──────────────────────────
  // Light
  static const lBgPrimary = Color(0xFFFFFFFF);
  static const lBgSecondary = Color(0xFFF7F8FA);
  static const lBgTertiary = Color(0xFFEFF1F4);
  static const lTextPrimary = Color(0xFF0F1419);
  static const lTextSecondary = Color(0xFF5C6470);
  static const lTextTertiary = Color(0xFF9AA0AB);
  static const lBorder = Color(0xFFE5E7EB);
  static const lAccent = Color(0xFF3B82F6);
  static const lAccentHover = Color(0xFF2563EB);
  static const lCard = Color(0xFFFFFFFF);
  static const lShadow = Color(0x0A0F1419); // rgba(15,20,25,0.04)

  // Dark
  static const dBgPrimary = Color(0xFF17212B);
  static const dBgSecondary = Color(0xFF1C2733);
  static const dBgTertiary = Color(0xFF232E3C);
  static const dTextPrimary = Color(0xFFFFFFFF);
  static const dTextSecondary = Color(0xFFAAB6C2);
  static const dTextTertiary = Color(0xFF6B7785);
  static const dBorder = Color(0xFF2C3845);
  static const dAccent = Color(0xFF5EA6FB);
  static const dAccentHover = Color(0xFF7BB8FF);
  static const dCard = Color(0xFF1C2733);
  static const dShadow = Color(0x4D000000); // rgba(0,0,0,0.3)

  // Semantic — одинаковы в обеих темах
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B); // streak / orange
  static const danger = Color(0xFFEF4444);
  static const anti = Color(0xFF10B981); // emerald — анти-привычки
  static const premium = Color(0xFFA855F7); // purple — premium badge

  static const chartPink = Color(0xFFEC4899);
  static const chartTeal = Color(0xFF06B6D4);

  /// Каноничный порядок цветов для линий/баров. Не пересоздавай вручную —
  /// добавляй новый цвет в конец и проверь, что Analytics не «дёрнулась».
  static const chartPalette = <Color>[
    success,   // 0 — основной (зелёный)
    lAccent,   // 1 — синий (одинаков в light/dark, поэтому берём light)
    warning,   // 2 — оранжевый
    premium,   // 3 — фиолетовый
    chartPink, // 4 — розовый
    chartTeal, // 5 — бирюзовый (Teal)
    danger,    // 6 — красный
    anti,      // 7 — эмеральд (анти-привычки)
  ];

  // ───────────────────────── RADIUS ──────────────────────────
  static const rSm = 8.0;
  static const rMd = 12.0;
  static const rLg = 16.0;
  static const rXl = 24.0;
  static const rFull = 999.0;

  // ───────────────────────── SPACING (8px grid) ──────────────
  static const s4 = 4.0;
  static const s8 = 8.0;
  static const s12 = 12.0;
  static const s16 = 16.0;
  static const s20 = 20.0;
  static const s24 = 24.0;
  static const s32 = 32.0;
  static const s48 = 48.0;
  static const s64 = 64.0;

  // ───────────────────────── TYPOGRAPHY ──────────────────────
  // font-family: system-ui, -apple-system, "SF Pro Text", "Segoe UI", Roboto
  // На вебе/iOS/Android Flutter подставит system по умолчанию — не указываем явно.

  // text-2xl · 28 / 700 · lh 1.2  — крупный счётчик стрика
  static const tsDisplay = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  // text-xl · 22 / 700 — Screen Title
  static const tsTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: -0.02 * 22, // -0.02em
  );

  // text-lg · 18 / 600 — Section Subheading
  static const tsSubheading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // text-base · 16 / 400 — body
  static const tsBody = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // text-sm · 14 / 400 — secondary description
  static const tsSecondary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // text-xs · 12 / 500 — LABEL/META/TIMESTAMP (uppercase в UI)
  static const tsLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  // Section labels (sticky headers): 11/700 uppercase letter-spacing 0.08em
  static const tsSectionLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.08 * 11,
  );

  // ───────────────────────── SHADOWS ─────────────────────────
  // Card: 0 2px 8px var(--shadow)
  static List<BoxShadow> cardShadow(Color shadow) => [
        BoxShadow(color: shadow, offset: const Offset(0, 2), blurRadius: 8),
      ];

  // Toast: 0 4px 16px var(--shadow)
  static List<BoxShadow> toastShadow(Color shadow) => [
        BoxShadow(color: shadow, offset: const Offset(0, 4), blurRadius: 16),
      ];

  // Bottom nav: 0 -2px 20px var(--shadow)
  static List<BoxShadow> bottomNavShadow(Color shadow) => [
        BoxShadow(color: shadow, offset: const Offset(0, -2), blurRadius: 20),
      ];

  // Slider thumb: 0 1px 4px var(--shadow)
  static List<BoxShadow> thumbShadow(Color shadow) => [
        BoxShadow(color: shadow, offset: const Offset(0, 1), blurRadius: 4),
      ];

  // Toggle thumb: 0 1px 4px rgba(0,0,0,0.15)
  static const toggleThumbShadow = [
    BoxShadow(color: Color(0x26000000), offset: Offset(0, 1), blurRadius: 4),
  ];
}

/// Палитра, применённая к текущему `BuildContext` (light или dark).
/// Используй `HFColors.of(context)` вместо хардкода в виджетах.
@immutable
class HFColors extends ThemeExtension<HFColors> {
  const HFColors({
    required this.bgPrimary,
    required this.bgSecondary,
    required this.bgTertiary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.accent,
    required this.accentHover,
    required this.card,
    required this.shadow,
  });

  final Color bgPrimary;
  final Color bgSecondary;
  final Color bgTertiary;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color border;
  final Color accent;
  final Color accentHover;
  final Color card;
  final Color shadow;

  // Семантические — одинаковы в обеих темах
  Color get success => HFTokens.success;
  Color get warning => HFTokens.warning;
  Color get danger => HFTokens.danger;
  Color get anti => HFTokens.anti;
  Color get premium => HFTokens.premium;

  static const light = HFColors(
    bgPrimary: HFTokens.lBgPrimary,
    bgSecondary: HFTokens.lBgSecondary,
    bgTertiary: HFTokens.lBgTertiary,
    textPrimary: HFTokens.lTextPrimary,
    textSecondary: HFTokens.lTextSecondary,
    textTertiary: HFTokens.lTextTertiary,
    border: HFTokens.lBorder,
    accent: HFTokens.lAccent,
    accentHover: HFTokens.lAccentHover,
    card: HFTokens.lCard,
    shadow: HFTokens.lShadow,
  );

  static const dark = HFColors(
    bgPrimary: HFTokens.dBgPrimary,
    bgSecondary: HFTokens.dBgSecondary,
    bgTertiary: HFTokens.dBgTertiary,
    textPrimary: HFTokens.dTextPrimary,
    textSecondary: HFTokens.dTextSecondary,
    textTertiary: HFTokens.dTextTertiary,
    border: HFTokens.dBorder,
    accent: HFTokens.dAccent,
    accentHover: HFTokens.dAccentHover,
    card: HFTokens.dCard,
    shadow: HFTokens.dShadow,
  );

  static HFColors of(BuildContext context) =>
      Theme.of(context).extension<HFColors>() ?? light;

  @override
  HFColors copyWith({
    Color? bgPrimary,
    Color? bgSecondary,
    Color? bgTertiary,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? border,
    Color? accent,
    Color? accentHover,
    Color? card,
    Color? shadow,
  }) {
    return HFColors(
      bgPrimary: bgPrimary ?? this.bgPrimary,
      bgSecondary: bgSecondary ?? this.bgSecondary,
      bgTertiary: bgTertiary ?? this.bgTertiary,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      border: border ?? this.border,
      accent: accent ?? this.accent,
      accentHover: accentHover ?? this.accentHover,
      card: card ?? this.card,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  HFColors lerp(ThemeExtension<HFColors>? other, double t) {
    if (other is! HFColors) return this;
    return HFColors(
      bgPrimary: Color.lerp(bgPrimary, other.bgPrimary, t)!,
      bgSecondary: Color.lerp(bgSecondary, other.bgSecondary, t)!,
      bgTertiary: Color.lerp(bgTertiary, other.bgTertiary, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      border: Color.lerp(border, other.border, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentHover: Color.lerp(accentHover, other.accentHover, t)!,
      card: Color.lerp(card, other.card, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}
