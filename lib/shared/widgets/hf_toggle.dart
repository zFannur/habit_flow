import 'package:flutter/material.dart';

import '../../core/config/tokens.dart';

/// Toggle (см. design-system.html → Inputs/Toggle).
/// Track 48×28 radius 14. Thumb 22×22 round. Off-thumb — text-tertiary,
/// on-thumb — белый. Анимация 200ms.
class HFToggle extends StatelessWidget {
  const HFToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);

    final track = GestureDetector(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 28,
        decoration: BoxDecoration(
          color: value ? c.accent : c.bgTertiary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              top: 3,
              left: value ? 23 : 3,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: value ? Colors.white : c.textTertiary,
                  shape: BoxShape.circle,
                  boxShadow: HFTokens.toggleThumbShadow,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (label == null) return track;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        track,
        const SizedBox(width: HFTokens.s12),
        Text(
          label!,
          style: TextStyle(
            fontSize: 14,
            color: c.textPrimary,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
