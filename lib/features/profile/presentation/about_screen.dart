import 'package:habit_flow/core/config/text_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/tokens.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/services/error_reporter.dart';
import '../../../shared/widgets/hf_header_bar.dart';

/// О приложении (SPEC §1 — концепция и принципы продукта).
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _version = '1.0.0';

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: c.bgSecondary,
      body: Column(
        children: [
          HFHeaderBar(title: l.aboutTitle, onBack: () => context.pop()),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
              children: [
                Center(
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [c.accent, const Color(0xFF7C3AED)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: c.accent.withValues(alpha: 0.3),
                          offset: const Offset(0, 8),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '🌱',
                      style: context.tt.displayLarge!.copyWith(height: 1, fontSize: 44.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'HabitFlow',
                    style: context.tt.headlineLarge!.copyWith(color: c.textPrimary, height: 1.2, letterSpacing: -0.02 * 26),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    l.aboutVersion(_version),
                    style: context.tt.bodySmall!.copyWith(color: c.textTertiary, height: 1.2),
                  ),
                ),
                const SizedBox(height: 24),
                _Section(
                  label: l.aboutWhatLabel,
                  body: l.aboutWhatText,
                ),
                const SizedBox(height: 16),
                _Section(
                  label: l.aboutPrinciplesLabel,
                  body: l.aboutPrinciplesText,
                ),
                const SizedBox(height: 16),
                _LinkRow(
                  emoji: '💬',
                  label: l.aboutChannelLink,
                  hint: '@habitflow_dev',
                ),
                if (kDebugMode) ...[
                  const SizedBox(height: 24),
                  _DebugLogsButton(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DebugLogsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return OutlinedButton.icon(
      onPressed: () async {
        await ErrorReporter.instance.copyToClipboard();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logs copied to clipboard')),
        );
      },
      icon: Icon(Icons.bug_report_outlined, color: c.textSecondary),
      label: Text(
        'Copy debug logs',
        style: context.tt.bodyMedium!.copyWith(color: c.textSecondary),
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
    return Container(
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
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.emoji, required this.label, required this.hint});

  final String emoji;
  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(HFTokens.rLg),
          border: Border.all(color: c.border, width: 1),
          boxShadow: HFTokens.cardShadow(c.shadow),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(emoji, style: context.tt.headlineMedium!.copyWith(height: 1)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: context.tt.titleMedium!.copyWith(color: c.textPrimary, height: 1.2),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hint,
                    style: context.tt.bodySmall!.copyWith(color: c.textTertiary, height: 1.2, fontSize: 12.0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
