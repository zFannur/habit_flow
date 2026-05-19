import 'package:flutter/material.dart';

import '../../../../core/config/tokens.dart';

/// Эмодзи-иконка привычки (см. today-screen.html — все карточки).
/// 44×44 квадрат, radius 12, опциональный tinted background.
class HabitEmojiIcon extends StatelessWidget {
  const HabitEmojiIcon({
    super.key,
    required this.emoji,
    this.tint,
    this.size = 44,
    this.fontSize = 22,
  });

  final String emoji;
  final Color? tint;
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tint ?? c.bgSecondary,
        borderRadius: BorderRadius.circular(HFTokens.rMd),
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: TextStyle(fontSize: fontSize, height: 1)),
    );
  }
}
