import 'package:flutter/material.dart';

import '../../core/config/tokens.dart';

/// Checkbox (см. design-system.html → Inputs/Checkbox).
/// 22×22, radius 6. Off — 1.5px border. On — заливка accent + белая галочка.
class HFCheckbox extends StatelessWidget {
  const HFCheckbox({
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

    final box = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: value ? c.accent : c.card,
        borderRadius: BorderRadius.circular(6),
        border: value ? null : Border.all(color: c.border, width: 1.5),
      ),
      alignment: Alignment.center,
      child: value
          ? const _CheckIcon()
          : null,
    );

    final tap = onChanged == null ? null : () => onChanged!(!value);

    if (label == null) {
      return GestureDetector(onTap: tap, child: box);
    }
    return GestureDetector(
      onTap: tap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          box,
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              label!,
              style: TextStyle(
                fontSize: 14,
                color: c.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckIcon extends StatelessWidget {
  const _CheckIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(13, 10),
      painter: _CheckPainter(),
    );
  }
}

class _CheckPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(1, 5)
      ..lineTo(5, 9)
      ..lineTo(12, 1);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
