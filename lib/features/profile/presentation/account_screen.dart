import 'package:habit_flow/core/config/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/tokens.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/services/locale_service.dart';
import '../../../shared/widgets/hf_header_bar.dart';

/// Аккаунт и язык. SPEC §10: язык RU/EN, первый день недели.
/// Telegram username — read-only из initData.
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  int _firstDayOfWeek = 1; // 1 = понедельник

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final lang = ref.watch(localeProvider).languageCode;
    return Scaffold(
      backgroundColor: c.bgSecondary,
      body: Column(
        children: [
          HFHeaderBar(title: l.accountTitle, onBack: () => context.pop()),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _Section(
                  label: l.accountTelegramSection,
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [c.accent, const Color(0xFF6366F1)],
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'N',
                          style: context.tt.headlineSmall!.copyWith(color: Colors.white, height: 1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nova',
                              style: context.tt.titleMedium!.copyWith(color: c.textPrimary, height: 1.2),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '@nova_habits',
                              style: context.tt.bodySmall!.copyWith(color: c.textTertiary, height: 1.2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _Section(
                  label: l.accountLanguageSection,
                  child: Column(
                    children: [
                      _RadioRow(
                        label: l.languageRussian,
                        selected: lang == 'ru',
                        onTap: () => ref.read(localeProvider.notifier).set('ru'),
                      ),
                      Divider(height: 1, color: c.border),
                      _RadioRow(
                        label: l.languageEnglish,
                        selected: lang == 'en',
                        onTap: () => ref.read(localeProvider.notifier).set('en'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _Section(
                  label: l.accountFirstDaySection,
                  child: Column(
                    children: [
                      _RadioRow(
                        label: l.accountFirstDayMonday,
                        selected: _firstDayOfWeek == 1,
                        onTap: () => setState(() => _firstDayOfWeek = 1),
                      ),
                      Divider(height: 1, color: c.border),
                      _RadioRow(
                        label: l.accountFirstDaySunday,
                        selected: _firstDayOfWeek == 7,
                        onTap: () => setState(() => _firstDayOfWeek = 7),
                      ),
                    ],
                  ),
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
  const _Section({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
          child: Text(
            label.toUpperCase(),
            style: context.tt.labelSmall!.copyWith(color: c.textTertiary, letterSpacing: 0.08 * 11),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(HFTokens.rLg),
            border: Border.all(color: c.border, width: 1),
            boxShadow: HFTokens.cardShadow(c.shadow),
          ),
          padding: const EdgeInsets.all(HFTokens.s16),
          child: child,
        ),
      ],
    );
  }
}

class _RadioRow extends StatelessWidget {
  const _RadioRow({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? c.accent : c.border,
                  width: selected ? 2 : 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: selected
                  ? Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: c.accent,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: context.tt.titleMedium!.copyWith(color: c.textPrimary, height: 1.2, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
