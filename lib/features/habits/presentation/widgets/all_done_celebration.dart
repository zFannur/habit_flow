import 'package:habit_flow/core/config/text_theme.dart';
import 'dart:math';

import 'package:flutter/material.dart';
import '../../../../core/localization/generated/app_localizations.dart';

class AllDoneCelebration extends StatefulWidget {
  const AllDoneCelebration({super.key, required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  State<AllDoneCelebration> createState() => _AllDoneCelebrationState();
}

class _AllDoneCelebrationState extends State<AllDoneCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..forward();

  static const _emojis = ['🎉', '✨', '⭐', '🎊', '💫', '🌟'];
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _particles = List.generate(24, (i) {
      return _Particle(
        emoji: _emojis[rng.nextInt(_emojis.length)],
        startX: rng.nextDouble(),
        delay: rng.nextDouble() * 0.3,
        speed: 0.8 + rng.nextDouble() * 0.4,
        rotateDirection: rng.nextBool() ? 1.0 : -1.0,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss,
      child: Container(
        color: Colors.black.withValues(alpha: 0.4),
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final size = MediaQuery.sizeOf(context);
                return Stack(
                  children: [
                    for (final p in _particles)
                      Positioned(
                        left: p.startX * size.width,
                        top: -40 +
                            (size.height + 80) *
                                ((_controller.value - p.delay) * p.speed)
                                    .clamp(0.0, 1.0),
                        child: Transform.rotate(
                          angle: _controller.value *
                              p.rotateDirection *
                              4 *
                              pi,
                          child: Text(
                            p.emoji,
                            style: context.tt.displayMedium!.copyWith(fontSize: 32.0),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🎉', style: context.tt.displayLarge!.copyWith(fontSize: 56.0)),
                    SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context).todayAllDoneTitle,
                      style: context.tt.headlineSmall!.copyWith(color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Particle {
  _Particle({
    required this.emoji,
    required this.startX,
    required this.delay,
    required this.speed,
    required this.rotateDirection,
  });

  final String emoji;
  final double startX;
  final double delay;
  final double speed;
  final double rotateDirection;
}
