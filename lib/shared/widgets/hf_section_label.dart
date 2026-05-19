import 'package:flutter/material.dart';

import '../../core/config/tokens.dart';

/// Sticky section label (см. design-system.html → .section-label).
/// 11/700 uppercase, letter-spacing 0.08em, padding 24/20/10/20,
/// background bg-secondary.
class HFSectionLabel extends StatelessWidget {
  const HFSectionLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Container(
      width: double.infinity,
      color: c.bgSecondary,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.08 * 11,
          color: c.textTertiary,
        ),
      ),
    );
  }
}
