import 'package:habit_flow/core/config/text_theme.dart';
import 'package:flutter/material.dart';

import '../../core/config/tokens.dart';

enum HFToastVariant { success, warning, info }

/// Toast / Banner (см. design-system.html → Toasts).
/// radius 14, 4px left border (variant), padding 14×16,
/// иконка в 36×36 tinted box, shadow 0 4px 16px.
class HFToast extends StatelessWidget {
  const HFToast({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.variant = HFToastVariant.info,
  });

  final String title;
  final String message;
  final IconData icon;
  final HFToastVariant variant;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);

    final accent = switch (variant) {
      HFToastVariant.success => c.success,
      HFToastVariant.warning => c.warning,
      HFToastVariant.info => c.accent,
    };
    final bg = accent.withValues(alpha: 0.08);

    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          top: BorderSide(color: c.border, width: 1),
          right: BorderSide(color: c.border, width: 1),
          bottom: BorderSide(color: c.border, width: 1),
          left: BorderSide(color: accent, width: 4),
        ),
        boxShadow: HFTokens.toastShadow(c.shadow),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.tt.labelLarge!.copyWith(color: c.textPrimary, height: 1.2),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: context.tt.bodySmall!.copyWith(color: c.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
