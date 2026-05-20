import 'package:habit_flow/core/config/text_theme.dart';
import 'package:flutter/material.dart';

import '../../../../core/config/tokens.dart';
import 'habit_emoji_icon.dart';

/// Количественная карточка (см. today-screen.html → CountableCard).
/// Кнопка +1 — 36×36 круг с rgba(accent,0.1) фоном.
/// Прогресс-бар: 5px высота, radius 999, fill переходит в success при done.
///
/// [onProgress] вызывается после каждого нажатия +1 с новым текущим значением.
class CountableHabitCard extends StatefulWidget {
  const CountableHabitCard({
    super.key,
    required this.emoji,
    this.iconTelegramFileId,
    required this.name,
    required this.initial,
    required this.total,
    required this.unit,
    this.onProgress,
  });

  final String emoji;
  final String? iconTelegramFileId;
  final String name;
  final int initial;
  final int total;
  final String unit;

  /// Called after +1 tap; receives the new current value.
  final void Function(int value)? onProgress;

  @override
  State<CountableHabitCard> createState() => _CountableHabitCardState();
}

class _CountableHabitCardState extends State<CountableHabitCard> {
  late int _current = widget.initial;

  @override
  void didUpdateWidget(CountableHabitCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initial != widget.initial) {
      _current = widget.initial;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final done = _current >= widget.total;
    final pct = (_current / widget.total).clamp(0.0, 1.0);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: done ? 0.62 : 1,
      child: Container(
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(HFTokens.rLg),
          border: Border.all(color: c.border, width: 1),
          boxShadow: HFTokens.cardShadow(c.shadow),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: [
            Row(
              children: [
                HabitEmojiIcon(
                  emoji: widget.emoji,
                  iconTelegramFileId: widget.iconTelegramFileId,
                  tint: c.accent.withValues(alpha: 0.08),
                ),
                const SizedBox(width: HFTokens.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: context.tt.titleMedium!.copyWith(color: c.textPrimary, height: 1.3),
                      ),
                      const SizedBox(height: 2),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '$_current',
                              style: context.tt.labelMedium!.copyWith(color: c.accent),
                            ),
                            TextSpan(
                              text: ' / ${widget.total} ${widget.unit}',
                              style: context.tt.bodySmall!.copyWith(color: c.textTertiary, fontSize: 12.0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: HFTokens.s12),
                _PlusButton(
                  onTap: () {
                    final next = (_current + 1).clamp(0, widget.total + 2);
                    setState(() => _current = next);
                    widget.onProgress?.call(next);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(HFTokens.rFull),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 5,
                backgroundColor: c.bgTertiary,
                valueColor: AlwaysStoppedAnimation(done ? c.success : c.accent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlusButton extends StatelessWidget {
  const _PlusButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Material(
      color: c.accent.withValues(alpha: 0.1),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(Icons.add, size: 20, color: c.accent),
        ),
      ),
    );
  }
}
