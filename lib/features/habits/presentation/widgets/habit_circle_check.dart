import 'package:flutter/material.dart';

import '../../../../core/config/tokens.dart';

/// Круглый чекбокс на карточке привычки (см. today-screen.html → .circle-check).
/// 32×32 круг. Off — 2px border. On — заливка accent + белая галочка 15×12.
class HabitCircleCheck extends StatelessWidget {
  const HabitCircleCheck({
    super.key,
    required this.done,
    required this.onTap,
  });

  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: done ? c.accent : c.card,
          shape: BoxShape.circle,
          border: Border.all(
            color: done ? c.accent : c.border,
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: done ? const _Check() : null,
      ),
    );
  }
}

class _Check extends StatelessWidget {
  const _Check();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(15, 12), painter: _CheckPainter());
  }
}

class _CheckPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(1.5, 6)
      ..lineTo(5.5, 10)
      ..lineTo(13.5, 1.5);
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
