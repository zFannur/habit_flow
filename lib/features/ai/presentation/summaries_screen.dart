import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/config/tokens.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../shared/widgets/hf_error_state.dart';
import '../../journal/data/journal_providers.dart';
import '../data/ai_summaries_repository.dart';
import 'summary_detail_screen.dart';

/// Tab «Сводки»: список `ai_summaries` пользователя из Supabase + ghost-карточка
/// «следующая через N записей». Дизайн копируется из макета 1:1.
class SummariesScreen extends ConsumerWidget {
  const SummariesScreen({super.key});

  static const _summaryInterval = 30;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summariesAsync = ref.watch(aiSummariesProvider);
    final entryCountAsync = ref.watch(journalEntryCountProvider);

    return summariesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: HFErrorState(
          error: e,
          onRetry: () => ref.invalidate(aiSummariesProvider),
        ),
      ),
      data: (summaries) {
        final count = entryCountAsync.maybeWhen(
          data: (v) => v,
          orElse: () => 0,
        );
        final remaining = _summaryInterval - (count % _summaryInterval);
        return ListView(
          padding: const EdgeInsets.fromLTRB(
            HFTokens.s16,
            HFTokens.s12,
            HFTokens.s16,
            HFTokens.s8,
          ),
          children: [
            _InfoBanner(
              count: count,
              remaining: remaining == _summaryInterval ? 0 : remaining,
            ),
            const SizedBox(height: HFTokens.s12),
            for (int i = 0; i < summaries.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _SummaryCard(
                summary: summaries[i],
                isLatest: i == 0,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          SummaryDetailScreen(summaryId: summaries[i].id),
                    ),
                  );
                },
              ),
            ],
            if (summaries.isEmpty || remaining > 0) ...[
              if (summaries.isNotEmpty) const SizedBox(height: 10),
              _GhostCard(
                remaining: remaining == _summaryInterval ? 0 : remaining,
              ),
            ],
            const SizedBox(height: 4),
          ],
        );
      },
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.count, required this.remaining});

  final int count;
  final int remaining;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: c.accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(HFTokens.rMd),
        border: Border.all(
          color: c.accent.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(LucideIcons.info, size: 16, color: c.accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppLocalizations.of(context)
                  .aiSummariesInfoBanner(30, count, remaining),
              style: TextStyle(
                fontSize: 12.5,
                color: c.textSecondary,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.summary,
    required this.isLatest,
    this.onTap,
  });

  final AiSummary summary;
  final bool isLatest;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final df = DateFormat('d MMM', locale);
    final period =
        '${df.format(summary.rangeStartDate)} — ${df.format(summary.rangeEndDate)}';

    final iconBg = isLatest
        ? c.accent.withValues(alpha: 0.12)
        : c.accent.withValues(alpha: 0.07);

    final preview = _firstParagraph(summary.content);

    final card = Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(HFTokens.rLg),
        boxShadow: isLatest
            ? [
                BoxShadow(
                  color: c.accent.withValues(alpha: 0.10),
                  offset: const Offset(0, 4),
                  blurRadius: 16,
                ),
              ]
            : HFTokens.cardShadow(c.shadow),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(
                  LucideIcons.sparkles,
                  size: 20,
                  color: c.accent,
                ),
              ),
              const SizedBox(width: HFTokens.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: isLatest ? 52 : 0),
                      child: Text(
                        l.aiSummaryTitle(
                          summary.rangeStartN,
                          summary.rangeEndN,
                        ),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: c.textPrimary,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        period,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: c.textTertiary,
                          height: 1.4,
                        ),
                      ),
                    ),
                    if (preview.isNotEmpty)
                      Text(
                        preview,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: c.textTertiary,
                          height: 1.55,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (isLatest)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: c.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(HFTokens.rFull),
                ),
                child: Text(
                  l.aiSummariesBadgeNew,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: c.accent,
                    letterSpacing: 0.02 * 10,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Opacity(
              opacity: 0.35,
              child: Icon(
                LucideIcons.chevronRight,
                size: 16,
                color: c.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(HFTokens.rLg),
        child: card,
      ),
    );
  }
}

class _GhostCard extends StatelessWidget {
  const _GhostCard({required this.remaining});

  final int remaining;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);

    return Opacity(
      opacity: 0.5,
      child: Container(
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(HFTokens.rLg),
          boxShadow: HFTokens.cardShadow(c.shadow),
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: c.bgTertiary,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(
                LucideIcons.hourglass,
                size: 20,
                color: c.textTertiary,
              ),
            ),
            const SizedBox(width: HFTokens.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.emptyTitleNoSummaries,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: c.textTertiary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l.emptyDescNoSummaries(remaining),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: c.textTertiary,
                      height: 1.4,
                    ),
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

/// Берём первый абзац / первые ~180 символов из markdown как preview.
String _firstParagraph(String markdown) {
  if (markdown.isEmpty) return '';
  final cleaned = markdown
      .replaceAll(RegExp(r'^#{1,6}\s.*$', multiLine: true), '')
      .replaceAll(RegExp(r'[*_`>]'), '')
      .trim();
  final firstBlock = cleaned.split(RegExp(r'\n\s*\n')).firstWhere(
        (block) => block.trim().isNotEmpty,
        orElse: () => '',
      );
  final flat = firstBlock.replaceAll(RegExp(r'\s+'), ' ').trim();
  return flat;
}
