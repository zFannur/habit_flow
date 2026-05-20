import 'package:habit_flow/core/config/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/config/tokens.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../shared/widgets/hf_markdown.dart';
import '../data/ai_summaries_repository.dart';
import '../data/chat_providers.dart';
import '../data/openrouter_key_repository.dart';
import '../data/openrouter_models_repository.dart';

/// Detail-экран одной AI-сводки. Markdown рендерится упрощённым парсером —
/// без новых зависимостей: H1/H2/H3, маркер-списки, нумерованные списки и
/// абзацы с inline `**bold**` / `*italic*` / `` `code` ``.
class SummaryDetailScreen extends ConsumerWidget {
  const SummaryDetailScreen({super.key, required this.summaryId});

  final String summaryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final summaryAsync = ref.watch(aiSummaryByIdProvider(summaryId));

    return Scaffold(
      backgroundColor: c.bgSecondary,
      body: SafeArea(
        child: summaryAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => _ErrorView(
            message: l.splashAuthErrorDesc,
            onBack: () => Navigator.of(context).pop(),
          ),
          data: (summary) {
            if (summary == null) {
              return _ErrorView(
                message: l.emptyTitleNoSummaries,
                onBack: () => Navigator.of(context).pop(),
              );
            }
            return Column(
              children: [
                _Header(
                  title: l.aiSummaryTitle(
                    summary.rangeStartN,
                    summary.rangeEndN,
                  ),
                  onBack: () => Navigator.of(context).pop(),
                ),
                _Breadcrumb(summary: summary),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      HFTokens.s16,
                      HFTokens.s16,
                      HFTokens.s16,
                      HFTokens.s4,
                    ),
                    children: [
                      HfMarkdown(content: summary.content),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                _ActionBar(summary: summary),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.bgPrimary,
        border: Border(bottom: BorderSide(color: c.border, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Row(
        children: [
          _SquareBtn(icon: LucideIcons.arrowLeft, onTap: onBack),
          const SizedBox(width: HFTokens.s12),
          Expanded(
            child: Text(
              title,
              style: context.tt.titleLarge!.copyWith(color: c.textPrimary, height: 1.3, letterSpacing: -0.01 * 17),
            ),
          ),
          _SquareBtn(
            icon: LucideIcons.moreHorizontal,
            iconColor: c.textSecondary,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _SquareBtn extends StatelessWidget {
  const _SquareBtn({required this.icon, required this.onTap, this.iconColor});

  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: c.border, width: 1),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: iconColor ?? c.textPrimary),
        ),
      ),
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({required this.summary});

  final AiSummary summary;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final df = DateFormat('d MMM', locale);
    final period =
        '${df.format(summary.rangeStartDate)} — ${df.format(summary.rangeEndDate)}';

    final items = <_Crumb>[
      _Crumb(
        LucideIcons.bookOpen,
        l.aiSummaryTitle(summary.rangeStartN, summary.rangeEndN),
      ),
      _Crumb(LucideIcons.calendar, period),
      _Crumb(LucideIcons.bot, _shortModelName(summary.modelUsed)),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: c.bgPrimary,
        border: Border(bottom: BorderSide(color: c.border, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        runSpacing: 4,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0)
              Text(
                '•',
                style: context.tt.bodySmall!.copyWith(color: c.border, height: 1),
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(items[i].icon, size: 12, color: c.textTertiary),
                const SizedBox(width: 4),
                Text(
                  items[i].text,
                  style: context.tt.bodyMedium!.copyWith(color: c.textTertiary, height: 1.3, fontSize: 11.5),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Crumb {
  const _Crumb(this.icon, this.text);
  final IconData icon;
  final String text;
}

String _shortModelName(String full) {
  // openai/gpt-oss-120b:free → gpt-oss-120b
  final afterSlash = full.contains('/') ? full.split('/').last : full;
  return afterSlash.split(':').first;
}


class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onBack});

  final String message;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Column(
      children: [
        _Header(
          title: AppLocalizations.of(context).aiSummariesTab,
          onBack: onBack,
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: context.tt.bodySmall!.copyWith(color: c.textSecondary, height: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionBar extends ConsumerStatefulWidget {
  const _ActionBar({required this.summary});

  final AiSummary summary;

  @override
  ConsumerState<_ActionBar> createState() => _ActionBarState();
}

class _ActionBarState extends ConsumerState<_ActionBar> {
  bool _isRegenerating = false;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final summary = widget.summary;

    return Container(
      decoration: BoxDecoration(
        color: c.bgPrimary,
        border: Border(top: BorderSide(color: c.border, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isRegenerating
                    ? null
                    : () {
                        final prompt = '${l.aiSummaryChatPrompt}:\n\n${summary.content}';
                        ref.read(pendingPromptProvider.notifier).state = prompt;
                        ref.read(aiActiveTabProvider.notifier).state = 0;
                        context.go('/ai');
                      },
                borderRadius: BorderRadius.circular(HFTokens.rMd),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _isRegenerating
                        ? c.accent.withValues(alpha: 0.5)
                        : c.accent,
                    borderRadius: BorderRadius.circular(HFTokens.rMd),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('💬', style: context.tt.bodyLarge!.copyWith(height: 1)),
                      const SizedBox(width: 7),
                      Text(
                        l.aiSummaryAsk,
                        style: context.tt.labelLarge!.copyWith(color: Colors.white, height: 1.2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isRegenerating
                  ? null
                  : () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: c.card,
                          title: Text(
                            l.aiSummaryRegenerateConfirmTitle,
                            style: context.tt.titleMedium!.copyWith(color: c.textPrimary),
                          ),
                          content: Text(
                            l.aiSummaryRegenerateConfirmText,
                            style: context.tt.bodyMedium!.copyWith(color: c.textSecondary),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text(
                                l.commonCancel,
                                style: TextStyle(color: c.textSecondary),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text(
                                l.aiSummaryRegenerate,
                                style: TextStyle(
                                  color: c.accent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm != true) return;

                      setState(() {
                        _isRegenerating = true;
                      });

                      try {
                        final key = await ref.read(openRouterKeyProvider.future);
                        final preferred = ref.read(preferredModelControllerProvider).value;

                        final repo = ref.read(aiSummariesRepositoryProvider);
                        final newSummaryId = await repo.regenerate(
                          rangeEndN: summary.rangeEndN,
                          openRouterKey: key,
                          model: preferred,
                        );

                        // Delete the old summary row so it is replaced
                        await repo.deleteSummary(summary.id);

                        if (context.mounted) {
                          context.replace('/summary/$newSummaryId');
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l.aiChatErrorGeneric),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isRegenerating = false;
                          });
                        }
                      }
                    },
              borderRadius: BorderRadius.circular(HFTokens.rMd),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(HFTokens.rMd),
                  border: Border.all(color: c.border, width: 1.5),
                ),
                child: Row(
                  children: [
                    if (_isRegenerating)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: c.textSecondary,
                        ),
                      )
                    else
                      Text('🔄', style: context.tt.bodyLarge!.copyWith(height: 1)),
                    const SizedBox(width: 7),
                    Text(
                      l.aiSummaryRegenerate,
                      style: context.tt.labelLarge!.copyWith(color: c.textSecondary, height: 1.2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
