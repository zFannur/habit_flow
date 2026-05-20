import 'package:habit_flow/core/config/text_theme.dart';
import 'package:flutter/material.dart';

import '../../core/config/tokens.dart';

enum HFBadgeVariant { streak, newBadge, premium, done }

/// Pill-бейдж (см. design-system.html → Badges).
/// padding 3×10, radius 999, fontSize 11/700, letter-spacing 0.02em.
class HFBadge extends StatelessWidget {
  const HFBadge({
    super.key,
    required this.label,
    this.variant = HFBadgeVariant.newBadge,
  });

  final String label;
  final HFBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);

    final (bg, fg) = switch (variant) {
      HFBadgeVariant.streak => (
          c.warning.withValues(alpha: 0.12),
          c.warning,
        ),
      HFBadgeVariant.newBadge => (
          c.accent.withValues(alpha: 0.12),
          c.accent,
        ),
      HFBadgeVariant.premium => (
          c.premium.withValues(alpha: 0.12),
          c.premium,
        ),
      HFBadgeVariant.done => (
          c.success.withValues(alpha: 0.12),
          c.success,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(HFTokens.rFull),
      ),
      child: Text(
        label,
        style: context.tt.labelSmall!.copyWith(color: fg, height: 1.2, letterSpacing: 0.02 * 11),
      ),
    );
  }
}
