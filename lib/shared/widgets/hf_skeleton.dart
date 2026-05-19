import 'package:flutter/material.dart';

import '../../core/config/tokens.dart';

/// Shimmer skeleton placeholder.
///
/// Renders a rounded rectangle with a sliding gradient shimmer animation.
/// Use multiple instances to sketch the shape of a real content area.
class HFSkeleton extends StatefulWidget {
  const HFSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.radius = HFTokens.rMd,
  });

  final double width;
  final double height;
  final double radius;

  @override
  State<HFSkeleton> createState() => _HFSkeletonState();
}

class _HFSkeletonState extends State<HFSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final base = c.bgTertiary;
    final shimmer = c.bgSecondary;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        final slide = _ctrl.value * 2 - 0.5;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(slide - 1, 0),
              end: Alignment(slide + 1, 0),
              colors: [base, shimmer, base],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}
