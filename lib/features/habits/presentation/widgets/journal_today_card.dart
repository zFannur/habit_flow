import 'package:flutter/material.dart';

import '../../../../core/config/tokens.dart';
import '../../../../core/localization/generated/app_localizations.dart';

/// Карточка дневника на экране Сегодня (см. today-screen.html → JournalCard).
/// Градиент 135deg #1a1a4e → #2d1b69 → #0f3460 (light),
/// в dark — чуть темнее. Белые точки-звёзды по фону.
/// Состояние "не написано": эмодзи 📝, заголовок "Запиши день",
/// подзаголовок и frosted-кнопка "Открыть".
/// Состояние "написано": ✅, время и превью записи + ссылка "Дополнить".
class JournalTodayCard extends StatelessWidget {
  const JournalTodayCard({
    super.key,
    this.written = false,
    required this.onOpen,
  });

  final bool written;
  final VoidCallback onOpen;

  static const _starsLight = [
    _Star(top: 0.12, left: 0.68, size: 3),
    _Star(top: 0.25, left: 0.82, size: 2),
    _Star(top: 0.55, left: 0.75, size: 2),
    _Star(top: 0.70, left: 0.90, size: 3),
    _Star(top: 0.40, left: 0.95, size: 1.5),
    _Star(top: 0.80, left: 0.60, size: 1.5),
    _Star(top: 0.15, left: 0.55, size: 1.5),
  ];

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final gradient = isDark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D0D2B), Color(0xFF1A0F3A), Color(0xFF041A35)],
            stops: [0.0, 0.4, 1.0],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A4E), Color(0xFF2D1B69), Color(0xFF0F3460)],
            stops: [0.0, 0.4, 1.0],
          );

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 110),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: c.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: c.shadow,
                offset: const Offset(0, 2),
                blurRadius: 12,
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(decoration: BoxDecoration(gradient: gradient)),
              ),
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (_, box) => Stack(
                    children: [
                      for (final s in _starsLight)
                        Positioned(
                          top: s.top * box.maxHeight,
                          left: s.left * box.maxWidth,
                          child: Container(
                            width: s.size,
                            height: s.size,
                            decoration: const BoxDecoration(
                              color: Color(0x66FFFFFF),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      written ? '✅' : '📝',
                      style: const TextStyle(fontSize: 32, height: 1),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: written
                          ? const _WrittenContent()
                          : _NotWrittenContent(onOpen: onOpen),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotWrittenContent extends StatelessWidget {
  const _NotWrittenContent({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l.journalCardTitle,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          l.journalCardSubtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0x99FFFFFF),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        _FrostedButton(label: l.commonOpen, onTap: onOpen),
      ],
    );
  }
}

class _WrittenContent extends StatelessWidget {
  const _WrittenContent();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Запись сделана в 22:14',
          style: TextStyle(
            fontSize: 12,
            color: Color(0x99FFFFFF),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          '«Сегодня удалось сохранить спокойствие в сложной ситуации...»',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            color: Color(0xD9FFFFFF),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {},
          child: Padding(
            padding: EdgeInsets.zero,
            child: Text(
              l.journalCardEditLink,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xBFFFFFFF),
                height: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FrostedButton extends StatelessWidget {
  const _FrostedButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x33FFFFFF),
      borderRadius: BorderRadius.circular(HFTokens.rFull),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(HFTokens.rFull),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(HFTokens.rFull),
            border: Border.all(color: const Color(0x59FFFFFF), width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _Star {
  const _Star({required this.top, required this.left, required this.size});
  final double top;
  final double left;
  final double size;
}
