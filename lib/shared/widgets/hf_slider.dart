import 'package:flutter/material.dart';

import '../../core/config/tokens.dart';

/// Slider (см. design-system.html → Inputs/Slider).
/// Track 4px radius 2 background bg-tertiary. Thumb 20×20 круг,
/// заливка accent, белый бордер 3px (= var(--card)), shadow 0 1px 4px var(--shadow).
class HFSlider extends StatelessWidget {
  const HFSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 100,
    this.divisions,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int? divisions;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 4,
        activeTrackColor: c.accent,
        inactiveTrackColor: c.bgTertiary,
        thumbColor: c.accent,
        overlayColor: c.accent.withValues(alpha: 0.15),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
        thumbShape: HFSliderThumbShape(
          borderColor: c.card,
          shadowColor: c.shadow,
        ),
        trackShape: const RoundedRectSliderTrackShape(),
      ),
      child: Slider(
        value: value.clamp(min, max),
        onChanged: onChanged,
        min: min,
        max: max,
        divisions: divisions,
      ),
    );
  }
}

/// Public thumb shape reused by HFSlider and other custom sliders.
/// Draws a circle with [borderColor] ring and a drop shadow.
class HFSliderThumbShape extends SliderComponentShape {
  const HFSliderThumbShape({
    required this.borderColor,
    required this.shadowColor,
    this.radius = 10.0,
    this.border = 3.0,
  });

  final Color borderColor;
  final Color shadowColor;
  final double radius;
  final double border;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size.fromRadius(radius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    canvas.drawCircle(
      center.translate(0, 1),
      radius,
      Paint()
        ..color = shadowColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(center, radius, Paint()..color = borderColor);
    canvas.drawCircle(
      center,
      radius - border,
      Paint()..color = sliderTheme.thumbColor!,
    );
  }
}
