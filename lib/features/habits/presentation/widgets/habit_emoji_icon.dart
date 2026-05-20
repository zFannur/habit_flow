import 'package:habit_flow/core/config/text_theme.dart';
import 'package:flutter/material.dart';

import '../../../../core/config/env.dart';
import '../../../../core/config/tokens.dart';

/// Эмодзи-иконка привычки (см. today-screen.html — все карточки).
/// 44×44 квадрат, radius 12, опциональный tinted background.
class HabitEmojiIcon extends StatelessWidget {
  const HabitEmojiIcon({
    super.key,
    required this.emoji,
    this.iconTelegramFileId,
    this.tint,
    this.size = 44,
    this.fontSize = 22,
  });

  final String emoji;
  final String? iconTelegramFileId;
  final Color? tint;
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);

    Widget content;
    if (iconTelegramFileId != null && iconTelegramFileId!.isNotEmpty) {
      final imageUrl = '${Env.supabaseUrl}/functions/v1/get_telegram_photo?file_id=$iconTelegramFileId';
      content = ClipRRect(
        borderRadius: BorderRadius.circular(HFTokens.rMd),
        child: Image.network(
          imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Text(
                emoji,
                style: context.tt.bodyMedium!.copyWith(height: 1, fontSize: fontSize),
              ),
            );
          },
        ),
      );
    } else {
      content = Text(
        emoji,
        style: context.tt.bodyMedium!.copyWith(height: 1, fontSize: fontSize),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tint ?? c.bgSecondary,
        borderRadius: BorderRadius.circular(HFTokens.rMd),
      ),
      alignment: Alignment.center,
      child: content,
    );
  }
}
