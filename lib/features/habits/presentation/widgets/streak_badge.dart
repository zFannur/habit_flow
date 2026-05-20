import 'package:habit_flow/core/config/text_theme.dart';
import 'package:flutter/material.dart';

import '../../../../core/config/tokens.dart';

/// Streak badge "🔥 14" (см. today-screen.html → .streak-badge).
/// Отличается от HFBadge: padding 3×8, gap 2, fontSize 11/700.
class StreakBadge extends StatelessWidget {
  const StreakBadge({super.key, required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(HFTokens.rFull),
      ),
      child: Text(
        '🔥 $days',
        style: context.tt.labelSmall!.copyWith(color: c.warning, height: 1.2),
      ),
    );
  }
}
