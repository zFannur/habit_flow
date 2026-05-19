import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/config/tokens.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../shared/widgets/hf_header_bar.dart';

/// Связаться с автором — пути контакта.
class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: c.bgSecondary,
      body: Column(
        children: [
          HFHeaderBar(title: l.contactTitle, onBack: () => context.pop()),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 14),
                  child: Text(
                    l.contactDesc,
                    style: TextStyle(
                      fontSize: 14,
                      color: c.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
                _ContactRow(
                  emoji: '💬',
                  label: l.contactChannelTelegram,
                  value: '@habitflow_dev',
                  iconBg: const Color(0x1F2AABEE),
                ),
                _ContactRow(
                  emoji: '📧',
                  label: l.contactChannelEmail,
                  value: 'hello@habitflow.app',
                  iconBg: const Color(0x1F22C55E),
                ),
                _ContactRow(
                  emoji: '🐙',
                  label: l.contactChannelGithub,
                  value: 'github.com/habitflow/issues',
                  iconBg: const Color(0x1F6B7280),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.emoji,
    required this.label,
    required this.value,
    required this.iconBg,
  });

  final String emoji;
  final String label;
  final String value;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(HFTokens.rLg),
          onTap: () async {
            final l = AppLocalizations.of(context);
            await Clipboard.setData(ClipboardData(text: value));
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l.contactCopiedToast(value)),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(HFTokens.rLg),
              border: Border.all(color: c.border, width: 1),
              boxShadow: HFTokens.cardShadow(c.shadow),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(emoji, style: const TextStyle(fontSize: 20, height: 1)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: c.textTertiary,
                          height: 1.2,
                          letterSpacing: 0.04 * 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: c.textPrimary,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(LucideIcons.copy, size: 18, color: c.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
