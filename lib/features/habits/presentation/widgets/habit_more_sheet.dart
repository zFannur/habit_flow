import 'package:habit_flow/core/config/text_theme.dart';
import 'package:flutter/material.dart';

import '../../../../core/config/tokens.dart';
import '../../../../core/localization/generated/app_localizations.dart';

/// Bottom-sheet "Подробнее" — показывает identity, reward, intention.
/// Вызывается при long-press на секцию "Поведенческие настройки".
class HabitMoreSheet extends StatelessWidget {
  const HabitMoreSheet({
    super.key,
    required this.identity,
    required this.reward,
    required this.implementationWhen,
    required this.implementationWhere,
  });

  final String? identity;
  final String? reward;
  final String? implementationWhen;
  final String? implementationWhere;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);

    final intentionParts = [
      implementationWhen,
      implementationWhere,
    ].whereType<String>().toList();
    final intentionValue =
        intentionParts.isNotEmpty ? intentionParts.join(', ') : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(HFTokens.rLg),
          border: Border.all(color: c.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Text(
                l.habitMoreSheetTitle,
                style: context.tt.bodyLarge!.copyWith(color: c.textPrimary, height: 1.2, fontWeight: FontWeight.w700),
              ),
            ),
            Container(height: 1, color: c.border),
            _SheetRow(
              emoji: '🎭',
              label: l.habitMoreSheetIdentity,
              value: identity,
              c: c,
              hasDivider: true,
            ),
            _SheetRow(
              emoji: '🎁',
              label: l.habitMoreSheetReward,
              value: reward,
              c: c,
              hasDivider: true,
            ),
            _SheetRow(
              emoji: '📍',
              label: l.habitMoreSheetIntention,
              value: intentionValue,
              c: c,
              hasDivider: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({
    required this.emoji,
    required this.label,
    required this.value,
    required this.c,
    required this.hasDivider,
  });

  final String emoji;
  final String label;
  final String? value;
  final HFColors c;
  final bool hasDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: hasDivider
            ? Border(bottom: BorderSide(color: c.border, width: 1))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: context.tt.headlineSmall!.copyWith(height: 1.3)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: context.tt.bodyMedium!.copyWith(color: c.textTertiary, height: 1.2, letterSpacing: 0.06 * 10, fontWeight: FontWeight.w700, fontSize: 10.0),
                ),
                const SizedBox(height: 2),
                Text(
                  value ?? '—',
                  style: context.tt.bodySmall!.copyWith(color: value != null ? c.textPrimary : c.textTertiary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
