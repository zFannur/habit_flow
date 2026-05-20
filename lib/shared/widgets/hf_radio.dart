import 'package:habit_flow/core/config/text_theme.dart';
import 'package:flutter/material.dart';

import '../../core/config/tokens.dart';

/// Radio (см. design-system.html → Inputs/Radio).
/// 22×22 круг. Off — 1.5px border. On — 2px accent border + 10px accent dot.
class HFRadio<T> extends StatelessWidget {
  const HFRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T>? onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final selected = value == groupValue;

    final dot = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: c.card,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? c.accent : c.border,
          width: selected ? 2 : 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: c.accent,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );

    final tap = onChanged == null ? null : () => onChanged!(value);

    if (label == null) {
      return GestureDetector(onTap: tap, child: dot);
    }
    return GestureDetector(
      onTap: tap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          dot,
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              label!,
              style: context.tt.bodyMedium!.copyWith(color: c.textPrimary, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
