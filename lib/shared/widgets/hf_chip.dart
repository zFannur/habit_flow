import 'package:habit_flow/core/config/text_theme.dart';
import 'package:flutter/material.dart';

import '../../core/config/tokens.dart';

/// Chip (см. design-system.html → Chips).
/// padding 6×14, radius 999, 1.5px border (accent если selected),
/// background rgba(accent,0.1) если selected.
/// Опциональный count в виде маленького круглого бейджа.
class HFChip extends StatelessWidget {
  const HFChip({
    super.key,
    required this.label,
    this.selected = false,
    this.count,
    this.onTap,
  });

  final String label;
  final bool selected;
  final int? count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final fg = selected ? c.accent : c.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(HFTokens.rFull),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? c.accent.withValues(alpha: 0.1) : c.card,
            borderRadius: BorderRadius.circular(HFTokens.rFull),
            border: Border.all(
              color: selected ? c.accent : c.border,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: context.tt.bodySmall!.copyWith(color: fg, height: 1.2),
              ),
              if (count != null) ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: selected ? c.accent : c.bgTertiary,
                    borderRadius: BorderRadius.circular(HFTokens.rFull),
                  ),
                  child: Text(
                    '$count',
                    style: context.tt.labelSmall!.copyWith(color: selected ? Colors.white : c.textTertiary, height: 1.2),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
