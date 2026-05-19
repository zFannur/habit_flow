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
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: c.textPrimary,
          height: 1.3,
        ),
      ),
      content: Text(
        l.aiChatDisclaimerText,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: c.textSecondary,
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: c.accent,
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: Text(l.commonUnderstand),
        ),
      ],
    );
  }
}
