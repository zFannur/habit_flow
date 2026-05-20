import 'package:habit_flow/core/config/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/tokens.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../shared/widgets/hf_header_bar.dart';

/// Политика приватности (SPEC §3 + Appendix A).
/// Краткая версия по принципам продукта; полная — отдельным документом
/// перед запуском.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: c.bgSecondary,
      body: Column(
        children: [
          HFHeaderBar(title: l.privacyTitle, onBack: () => context.pop()),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _Section(
                  label: l.privacyAuthLabel,
                  body: l.privacyAuthText,
                ),
                _Section(
                  label: l.privacyStorageLabel,
                  body: l.privacyStorageText,
                ),
                _Section(
                  label: l.privacyKeyLabel,
                  body: l.privacyKeyText,
                ),
                _Section(
                  label: l.privacyNotCollectLabel,
                  body: l.privacyNotCollectText,
                ),
                _Section(
                  label: l.privacyDeletionLabel,
                  body: l.privacyDeletionText,
                ),
                _Section(
                  label: l.privacyContactLabel,
                  body: l.privacyContactText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.label, required this.body});

  final String label;
  final String body;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(HFTokens.rLg),
          border: Border.all(color: c.border, width: 1),
          boxShadow: HFTokens.cardShadow(c.shadow),
        ),
        padding: const EdgeInsets.all(HFTokens.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: context.tt.labelSmall!.copyWith(color: c.textTertiary, letterSpacing: 0.08 * 11),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: context.tt.bodyMedium!.copyWith(color: c.textPrimary, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
