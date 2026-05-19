import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/config/tokens.dart';
import '../../../../core/localization/generated/app_localizations.dart';

/// Voscresenie review-cheklist, otkryvaetsja kogda v query parametrah ?review=1.
/// Pokazyvaet 3 punkta: streak, korreljacii, celi. Otmechaem lokal'no v state.
class WeeklyReviewChecklist extends StatefulWidget {
  const WeeklyReviewChecklist({super.key, this.onDismiss});

  final VoidCallback? onDismiss;

  @override
  State<WeeklyReviewChecklist> createState() => _WeeklyReviewChecklistState();
}

class _WeeklyReviewChecklistState extends State<WeeklyReviewChecklist> {
  final List<bool> _checked = [false, false, false];

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final items = [
      l.weeklyReviewItemStreak,
      l.weeklyReviewItemCorrelations,
      l.weeklyReviewItemGoals,
    ];

    return Container(
      key: const Key('weekly_review_checklist'),
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.bgSecondary,
        borderRadius: BorderRadius.circular(HFTokens.rLg),
        border: Border.all(color: c.border, width: 1),
        boxShadow: HFTokens.cardShadow(c.shadow),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: HFTokens.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  LucideIcons.calendarCheck,
                  size: 18,
                  color: HFTokens.warning,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l.weeklyReviewTitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                    height: 1.2,
                  ),
                ),
              ),
              if (widget.onDismiss != null)
                InkWell(
                  onTap: widget.onDismiss,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      LucideIcons.x,
                      size: 16,
                      color: c.textTertiary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l.weeklyReviewSubtitle,
            style: TextStyle(
              fontSize: 12,
              color: c.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _CheckItem(
              label: items[i],
              checked: _checked[i],
              onTap: () => setState(() => _checked[i] = !_checked[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  const _CheckItem({
    required this.label,
    required this.checked,
    required this.onTap,
  });

  final String label;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(HFTokens.rMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: checked ? HFTokens.success : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: checked ? HFTokens.success : c.border,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: checked
                  ? const Icon(LucideIcons.check, size: 13, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: checked ? c.textTertiary : c.textPrimary,
                  decoration: checked ? TextDecoration.lineThrough : null,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
