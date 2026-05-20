import 'package:habit_flow/core/config/text_theme.dart';
import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/config/tokens.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import 'habit_emoji_icon.dart';
import 'streak_badge.dart';

/// По длительности (см. today-screen.html → TimedCard).
/// Иконка на orange-tinted фоне (rgba(245,158,11,0.1)).
/// Когда таймер запущен — sub заменяется на MM:SS моноширинным шрифтом.
///
/// [onDone] вызывается при остановке таймера с количеством прошедших секунд.
class TimedHabitCard extends StatefulWidget {
  const TimedHabitCard({
    super.key,
    required this.emoji,
    this.iconTelegramFileId,
    required this.name,
    required this.subtitle,
    this.streak,
    this.initialDone = false,
    this.onDone,
  });

  final String emoji;
  final String? iconTelegramFileId;
  final String name;
  final String subtitle;
  final int? streak;
  final bool initialDone;

  /// Called when the user presses Pause (stops timer) with elapsed seconds.
  final void Function(int elapsedSeconds)? onDone;

  @override
  State<TimedHabitCard> createState() => _TimedHabitCardState();
}

class _TimedHabitCardState extends State<TimedHabitCard> {
  bool _running = false;
  int _elapsed = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _running = !_running;
      if (_running) {
        _timer = Timer.periodic(
          const Duration(seconds: 1),
          (_) => setState(() => _elapsed++),
        );
      } else {
        _timer?.cancel();
        widget.onDone?.call(_elapsed);
      }
    });
  }

  String _fmt(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);

    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(HFTokens.rLg),
        border: Border.all(color: c.border, width: 1),
        boxShadow: HFTokens.cardShadow(c.shadow),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          HabitEmojiIcon(
            emoji: widget.emoji,
            iconTelegramFileId: widget.iconTelegramFileId,
            tint: c.warning.withValues(alpha: 0.1),
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
                const SizedBox(height: 3),
                Row(
                  children: [
                    if (_running)
                      Text(
                        _fmt(_elapsed),
                        style: context.tt.labelMedium!.copyWith(color: c.accent),
                      )
                    else
                      Text(
                        widget.subtitle,
                        style: context.tt.bodySmall!.copyWith(color: c.textTertiary, fontSize: 12.0),
                      ),
                    if (widget.streak != null) ...[
                      const SizedBox(width: 8),
                      StreakBadge(days: widget.streak!),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: HFTokens.s12),
          _TimerPill(running: _running, onTap: _toggle),
        ],
      ),
    );
  }
}

class _TimerPill extends StatelessWidget {
  const _TimerPill({required this.running, required this.onTap});

  final bool running;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(HFTokens.rFull),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(HFTokens.rFull),
            border: Border.all(color: c.accent, width: 1.5),
          ),
          child: Text(
            running ? l.habitTimerPause : l.habitTimerStart,
            style: context.tt.titleSmall!.copyWith(color: c.accent, height: 1.2),
          ),
        ),
      ),
    );
  }
}
