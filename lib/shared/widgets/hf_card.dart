import 'package:flutter/material.dart';

import '../../core/config/tokens.dart';

/// Базовая карточка (см. design-system.html → Cards).
/// radius 16, border 1px var(--border), padding 16, shadow 0 2px 8px var(--shadow).
class HFCard extends StatelessWidget {
  const HFCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(HFTokens.s16),
    this.borderColor,
    this.borderWidth = 1,
    this.background,
    this.opacity = 1,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final double borderWidth;
  final Color? background;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);

    final card = Container(
      decoration: BoxDecoration(
        color: background ?? c.card,
        borderRadius: BorderRadius.circular(HFTokens.rLg),
        border: Border.all(
          color: borderColor ?? c.border,
          width: borderWidth,
        ),
        boxShadow: HFTokens.cardShadow(c.shadow),
      ),
      padding: padding,
      child: child,
    );

    final wrapped = opacity == 1 ? card : Opacity(opacity: opacity, child: card);

    if (onTap == null) return wrapped;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(HFTokens.rLg),
        child: wrapped,
      ),
    );
  }
}
