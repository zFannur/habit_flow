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
            style: const TextStyle(fontSize: 72, height: 1),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.2,
              letterSpacing: -0.01 * 18,
              color: c.textPrimary,
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: 10),
            Text(
              description!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.6,
                color: c.textSecondary,
              ),
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
