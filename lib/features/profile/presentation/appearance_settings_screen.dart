import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/config/tokens.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/services/theme_service.dart';

/// Настройки внешнего вида (отдельного дизайна в Claude Design нет —
/// собрано из theme switcher из design-system.html и палитры accent
/// из habit-wizard).
class AppearanceSettingsScreen extends ConsumerStatefulWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  ConsumerState<AppearanceSettingsScreen> createState() =>
      _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState
    extends ConsumerState<AppearanceSettingsScreen> {
  static const _defaultAccent = Color(0xFF3B82F6);

  static const _accentColors = <_AccentOption>[
    _AccentOption('blue', Color(0xFF3B82F6)),
    _AccentOption('green', Color(0xFF22C55E)),
    _AccentOption('amber', Color(0xFFF59E0B)),
    _AccentOption('red', Color(0xFFEF4444)),
    _AccentOption('violet', Color(0xFFA855F7)),
    _AccentOption('pink', Color(0xFFEC4899)),
    _AccentOption('teal', Color(0xFF06B6D4)),
    _AccentOption('gray', Color(0xFF6B7785)),
  ];

  String _accentLabel(AppLocalizations l, String key) {
    switch (key) {
      case 'blue':
        return l.accentBlue;
      case 'green':
        return l.accentGreen;
      case 'amber':
        return l.accentAmber;
      case 'red':
        return l.accentRed;
      case 'violet':
        return l.accentViolet;
      case 'pink':
        return l.accentPink;
      case 'teal':
        return l.accentTeal;
      case 'gray':
        return l.accentGray;
    }
    return key;
  }

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final themeNotifier = ref.watch(themeProvider.notifier);
    final themeKey = ref.watch(themeProvider).toKey();
    final accent = ref.watch(accentColorProvider) ?? _defaultAccent;
    return Scaffold(
      backgroundColor: c.bgSecondary,
      body: Column(
        children: [
          _Header(onBack: () => context.pop()),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Section(
                    label: l.appearanceThemeSection,
                    child: _ThemeSwitcher(
                      value: themeKey,
                      onChanged: (v) => themeNotifier.setFromKey(v),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Section(
                    label: l.appearanceAccentSection,
                    child: _AccentGrid(
                      accents: [
                        for (final a in _accentColors)
                          _AccentOption(_accentLabel(l, a.name), a.color),
                      ],
                      selected: accent,
                      onSelect: (col) => ref
                          .read(accentColorProvider.notifier)
                          .set(col == _defaultAccent ? null : col),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.bgPrimary,
        border: Border(bottom: BorderSide(color: c.border, width: 1)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
          child: Row(
            children: [
              InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(HFTokens.rSm),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 4, 6, 4),
                  child: Icon(
                    LucideIcons.chevronLeft,
                    size: 24,
                    color: c.accent,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                l.appearanceTitle,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                  letterSpacing: -0.02 * 20,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: c.textTertiary,
              letterSpacing: 0.08 * 11,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(HFTokens.rLg),
            border: Border.all(color: c.border, width: 1),
            boxShadow: HFTokens.cardShadow(c.shadow),
          ),
          padding: const EdgeInsets.all(HFTokens.s16),
          child: child,
        ),
      ],
    );
  }
}

class _ThemeSwitcher extends StatelessWidget {
  const _ThemeSwitcher({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final opts = [
      ('light', l.appearanceThemeLight),
      ('dark', l.appearanceThemeDark),
      ('auto', l.appearanceThemeAuto),
    ];
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: c.bgTertiary,
        borderRadius: BorderRadius.circular(HFTokens.rMd),
      ),
      child: Row(
        children: [
          for (final (key, label) in opts)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: value == key ? c.card : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: value == key
                        ? [
                            BoxShadow(
                              color: c.shadow,
                              offset: const Offset(0, 1),
                              blurRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: value == key ? c.textPrimary : c.textTertiary,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AccentGrid extends StatelessWidget {
  const _AccentGrid({
    required this.accents,
    required this.selected,
    required this.onSelect,
  });

  final List<_AccentOption> accents;
  final Color selected;
  final ValueChanged<Color> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final a in accents)
          GestureDetector(
            onTap: () => onSelect(a.color),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: a.color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected == a.color
                          ? a.color
                          : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: a.color.withValues(alpha: 0.3),
                        offset: const Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: selected == a.color
                      ? const Icon(
                          Icons.check,
                          size: 20,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(height: 4),
                Text(
                  a.name,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: HFColors.of(context).textTertiary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _AccentOption {
  const _AccentOption(this.name, this.color);
  final String name;
  final Color color;
}
