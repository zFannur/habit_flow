import 'package:habit_flow/core/config/text_theme.dart';
import 'package:flutter/material.dart';

import '../../../../core/config/tokens.dart';
import '../../../../core/localization/generated/app_localizations.dart';

/// Модальный диалог privacy-disclaimer для AI-вкладки.
///
/// Показывается ровно один раз — при первом открытии AI-tab после ввода ключа.
/// Текст соответствует SPEC §7.6.
class PrivacyDisclaimerDialog extends StatelessWidget {
  const PrivacyDisclaimerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = HFColors.of(context);

    return AlertDialog(
      backgroundColor: c.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HFTokens.rLg),
      ),
      title: Text(
        l.aiChatDisclaimerTitle,
        style: context.tt.titleLarge!.copyWith(color: c.textPrimary, height: 1.3),
      ),
      content: Text(
        l.aiChatDisclaimerText,
        style: context.tt.bodyMedium!.copyWith(color: c.textSecondary, height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: c.accent,
            textStyle: context.tt.titleMedium,
          ),
          child: Text(l.commonUnderstand),
        ),
      ],
    );
  }
}
