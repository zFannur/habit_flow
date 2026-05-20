import 'package:habit_flow/core/config/text_theme.dart';
import 'package:flutter/material.dart';

import '../../../../core/config/tokens.dart';
import '../../../../core/localization/generated/app_localizations.dart';

/// Анти-привычка (см. today-screen.html → AntiCard).
/// Фон карточки rgba(anti,0.06), бордер rgba(anti,0.25).
/// Слева — 64×64 box с большим числом дней + "ДНЕЙ" под ним.
/// Лейбл "{emoji} без" в anti-цвете, имя — 16/700.
/// Кнопка "Удержался" — green pill, рядом "⋯" overflow.
///
/// [onHeld] вызывается когда пользователь нажимает "Удержался".
class AntiHabitCard extends StatefulWidget {
  const AntiHabitCard({
    super.key,
    required this.emoji,
    required this.name,
    required this.days,
    this.initialHeld = false,
    this.onHeld,
  });

  final String emoji;
  final String name;
  final int days;
  final bool initialHeld;

  /// Called when user marks "Удержался" for today.
  final VoidCallback? onHeld;

  @override
  State<AntiHabitCard> createState() => _AntiHabitCardState();
}

class _AntiHabitCardState extends State<AntiHabitCard> {
  late bool _held = widget.initialHeld;

  @override
  void didUpdateWidget(AntiHabitCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialHeld != widget.initialHeld) {
      _held = widget.initialHeld;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: c.anti.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(HFTokens.rLg),
        border: Border.all(color: c.anti.withValues(alpha: 0.25), width: 1),
        boxShadow: HFTokens.cardShadow(c.shadow),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: c.anti.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(HFTokens.rLg),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${widget.days}',
                  style: context.tt.headlineLarge!.copyWith(color: c.anti, height: 1),
                ),
                const SizedBox(height: 1),
                Text(
                  l.habitAntiDays,
                  style: context.tt.bodyMedium!.copyWith(color: c.anti, height: 1, letterSpacing: 0.06 * 9, fontWeight: FontWeight.w700, fontSize: 9.0),
                ),
              ],
            ),
          ),
          const SizedBox(width: HFTokens.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${widget.emoji} без',
                  style: context.tt.labelMedium!.copyWith(color: c.anti, height: 1.2),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.name,
                  style: context.tt.bodyLarge!.copyWith(color: c.textPrimary, height: 1.2, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                if (_held)
                  Text(
                    l.habitAntiMarkedToday,
                    style: context.tt.labelMedium!.copyWith(color: c.anti, height: 1.2),
                  )
                else
                  Row(
                    children: [
                      _GreenPill(
                        label: l.habitAntiHeld,
                        onTap: () {
                          setState(() => _held = true);
                          widget.onHeld?.call();
                        },
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 4),
                          child: Text(
                            '⋯',
                            style: context.tt.headlineSmall!.copyWith(color: c.textTertiary, height: 1),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GreenPill extends StatelessWidget {
  const _GreenPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Material(
      color: c.anti,
      borderRadius: BorderRadius.circular(HFTokens.rFull),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(HFTokens.rFull),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Text(
            label,
            style: context.tt.labelMedium!.copyWith(color: Colors.white, height: 1.2),
          ),
        ),
      ),
    );
  }
}
