import 'package:flutter/material.dart';

import '../../../../core/config/tokens.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../domain/habit_log_status.dart';
import 'habit_circle_check.dart';
import 'habit_emoji_icon.dart';
import 'streak_badge.dart';

/// Бинарная карточка (см. today-screen.html → BinaryCard).
/// Выполненная: opacity 0.62, текст с line-through, иконка с accent-tint.
///
/// [onToggle] вызывается при каждом нажатии на чекбокс. Когда передан —
/// внешний слой управляет состоянием (realtime), иначе локальный state.
///
/// Поведенческие техники (SPEC §8):
///  * 08-01 Habit Stacking — если задан [stackAfterEmoji]+[stackAfterName],
///    показываем sub-line `После: <emoji> <name>`;
///  * 08-02 Implementation Intentions — если stack не задан, но есть
///    [implementationWhen]+[implementationWhere], показываем `<when> <where>`;
///  * 08-03 Two-Minute Rule — если задан [twoMinuteVersion], долгий тап
///    или длинное нажатие на чекбокс открывает bottom-sheet с выбором
///    "Полностью" / "Минимальный вариант". [onLog] предпочтителен в этом
///    случае: получает done или partial.
///
/// Если [onLog] передан — он используется при выборе варианта в шите.
/// Для совместимости [onToggle] продолжает вызываться при простом тапе.
class BinaryHabitCard extends StatefulWidget {
  const BinaryHabitCard({
    super.key,
    required this.emoji,
    required this.name,
    required this.subtitle,
    this.streak,
    this.initialDone = false,
    this.onToggle,
    this.onLog,
    this.stackAfterEmoji,
    this.stackAfterName,
    this.implementationWhen,
    this.implementationWhere,
    this.twoMinuteVersion,
  });

  final String emoji;
  final String name;
  final String subtitle;
  final int? streak;
  final bool initialDone;

  /// Called when the user taps the check circle.
  /// Receives the new desired done-state (true = mark done, false = undo).
  final void Function(bool done)? onToggle;

  /// Called from the two-minute bottom-sheet with an explicit log status
  /// (`done` or `partial`). When null, the sheet falls back to [onToggle].
  final void Function(HabitLogStatus status)? onLog;

  // Habit Stacking (08-01)
  final String? stackAfterEmoji;
  final String? stackAfterName;

  // Implementation Intentions (08-02)
  final String? implementationWhen;
  final String? implementationWhere;

  // Two-Minute Rule (08-03)
  final String? twoMinuteVersion;

  @override
  State<BinaryHabitCard> createState() => _BinaryHabitCardState();
}

class _BinaryHabitCardState extends State<BinaryHabitCard> {
  late bool _done = widget.initialDone;

  @override
  void didUpdateWidget(BinaryHabitCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialDone != widget.initialDone) {
      _done = widget.initialDone;
    }
  }

  /// Returns the optional behaviour-science sub-line, or `null` when none
  /// applies. Priority: stacking > implementation intention.
  String? _behaviourLine(AppLocalizations l) {
    final stackName = widget.stackAfterName;
    if (stackName != null && stackName.trim().isNotEmpty) {
      return l.habitCardStackAfter(
        widget.stackAfterEmoji ?? '',
        stackName,
      );
    }
    final when = widget.implementationWhen?.trim() ?? '';
    final where = widget.implementationWhere?.trim() ?? '';
    if (when.isNotEmpty && where.isNotEmpty) {
      return '$when $where';
    }
    return null;
  }

  Future<void> _handleTap() async {
    // If turning off, no need to ask — just toggle.
    final next = !_done;
    if (!next) {
      setState(() => _done = next);
      widget.onToggle?.call(false);
      return;
    }

    final twoMin = widget.twoMinuteVersion?.trim() ?? '';
    if (twoMin.isEmpty) {
      setState(() => _done = next);
      widget.onToggle?.call(true);
      return;
    }

    // Two-Minute Rule: ask the user which variant they finished.
    final picked = await _showTwoMinuteSheet(twoMin);
    if (picked == null) {
      // Cancelled — keep the previous state.
      return;
    }
    setState(() => _done = true);
    if (widget.onLog != null) {
      widget.onLog!(picked);
    } else {
      // Back-compat: legacy callers only know about done/missed.
      widget.onToggle?.call(true);
    }
  }

  Future<HabitLogStatus?> _showTwoMinuteSheet(String version) {
    return showModalBottomSheet<HabitLogStatus>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _TwoMinuteSheet(version: version),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final extraLine = _behaviourLine(l);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _done ? 0.62 : 1,
      child: Container(
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
              tint: _done ? c.accent.withValues(alpha: 0.08) : null,
            ),
            const SizedBox(width: HFTokens.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary,
                      height: 1.3,
                      decoration: _done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: c.textTertiary,
                          height: 1.2,
                        ),
                      ),
                      if (widget.streak != null) StreakBadge(days: widget.streak!),
                    ],
                  ),
                  if (extraLine != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      extraLine,
                      style: TextStyle(
                        fontSize: 11,
                        color: c.textTertiary,
                        height: 1.2,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: HFTokens.s12),
            HabitCircleCheck(
              done: _done,
              onTap: _handleTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _TwoMinuteSheet extends StatelessWidget {
  const _TwoMinuteSheet({required this.version});

  final String version;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(HFTokens.rLg),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: c.border,
                  borderRadius: BorderRadius.circular(HFTokens.rFull),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              l.habitCardLogSheetTitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            _SheetOption(
              title: l.habitCardLogSheetFull,
              subtitle: l.habitCardLogSheetFullSub,
              onTap: () => Navigator.of(context).pop(HabitLogStatus.done),
            ),
            const SizedBox(height: 8),
            _SheetOption(
              title: l.habitCardLogSheetMin,
              subtitle: l.habitCardLogSheetMinSub(version),
              onTap: () => Navigator.of(context).pop(HabitLogStatus.partial),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  const _SheetOption({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Material(
      color: c.bgSecondary,
      borderRadius: BorderRadius.circular(HFTokens.rLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(HFTokens.rLg),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: c.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: c.textTertiary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
