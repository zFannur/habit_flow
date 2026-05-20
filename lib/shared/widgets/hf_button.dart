import 'package:habit_flow/core/config/text_theme.dart';
import 'package:flutter/material.dart';

import '../../core/config/tokens.dart';

enum HFButtonVariant { primary, secondary, ghost, danger }

enum HFButtonSize { sm, md }

/// Кнопка дизайн-системы (см. design-system.html → Buttons).
/// MD: padding 12×24, fontSize 15, weight 600.
/// SM: padding 8×16, fontSize 13, weight 600.
class HFButton extends StatelessWidget {
  const HFButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = HFButtonVariant.primary,
    this.size = HFButtonSize.md,
    this.icon,
    this.iconAtEnd = false,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final HFButtonVariant variant;
  final HFButtonSize size;
  final IconData? icon;
  final bool iconAtEnd;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final disabled = onPressed == null;

    final (bg, fg, border) = switch (variant) {
      HFButtonVariant.primary => (c.accent, Colors.white, null),
      HFButtonVariant.secondary => (
          Colors.transparent,
          c.accent,
          Border.all(color: c.accent, width: 1.5),
        ),
      HFButtonVariant.ghost => (Colors.transparent, c.textSecondary, null),
      HFButtonVariant.danger => (c.danger, Colors.white, null),
    };

    final pad = size == HFButtonSize.sm
        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
        : const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    final fs = size == HFButtonSize.sm ? 13.0 : 15.0;
    final iconSize = size == HFButtonSize.sm ? 14.0 : 16.0;

    final children = <Widget>[
      if (icon != null && !iconAtEnd) ...[
        Icon(icon, size: iconSize, color: fg),
        const SizedBox(width: HFTokens.s4),
      ],
      Text(
        label,
        style: (size == HFButtonSize.sm
                ? context.tt.labelMedium!
                : context.tt.labelLarge!)
            .copyWith(color: fg, fontSize: fs, height: 1.2),
      ),
      if (icon != null && iconAtEnd) ...[
        const SizedBox(width: HFTokens.s4),
        Icon(icon, size: iconSize, color: fg),
      ],
    ];

    Widget content = AnimatedOpacity(
      opacity: disabled ? 0.4 : 1,
      duration: const Duration(milliseconds: 150),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(HFTokens.rMd),
          border: border,
        ),
        padding: pad,
        child: Row(
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onPressed,
        borderRadius: BorderRadius.circular(HFTokens.rMd),
        child: content,
      ),
    );
  }
}
