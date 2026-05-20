import 'package:habit_flow/core/config/text_theme.dart';
import 'package:flutter/material.dart';

import '../../core/config/tokens.dart';

/// Empty-state виджет (см. docs/design/empty-states.html).
/// Большой эмодзи 72px, заголовок 18/700, описание 14 lh1.6, опциональные CTA.
class HFEmptyState extends StatelessWidget {
  const HFEmptyState({
    super.key,
    required this.emoji,
    required this.title,
    this.description,
    this.action,
    this.secondaryAction,
    this.padding,
  });

  final String emoji;
  final String title;
  final String? description;
  final Widget? action;
  final Widget? secondaryAction;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);

    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            emoji,
            textAlign: TextAlign.center,
            style: context.tt.displayLarge!.copyWith(height: 1, fontSize: 72.0),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.tt.headlineSmall!.copyWith(color: c.textPrimary, height: 1.2, letterSpacing: -0.01 * 18),
          ),
          if (description != null) ...[
            const SizedBox(height: 10),
            Text(
              description!,
              textAlign: TextAlign.center,
              style: context.tt.bodyMedium!.copyWith(color: c.textSecondary, height: 1.6),
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: 28),
            action!,
          ],
          if (secondaryAction != null) ...[
            const SizedBox(height: 12),
            secondaryAction!,
          ],
        ],
      ),
    );
  }
}
