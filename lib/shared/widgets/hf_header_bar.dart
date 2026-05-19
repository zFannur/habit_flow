import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/config/tokens.dart';

/// Стандартный header полноэкранных пушей: chevronLeft + заголовок.
/// Цвет accent на стрелке, 20/700 -0.02em title.
class HFHeaderBar extends StatelessWidget {
  const HFHeaderBar({
    super.key,
    required this.title,
    required this.onBack,
    this.trailing,
  });

  final String title;
  final VoidCallback onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.bgPrimary,
        border: Border(bottom: BorderSide(color: c.border, width: 1)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
          child: Row(
            children: [
              InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(HFTokens.rSm),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 4, 6, 4),
                  child: Icon(
                    LucideIcons.chevronLeft,
                    size: 24,
                    color: c.accent,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                    letterSpacing: -0.02 * 20,
                    height: 1.2,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
