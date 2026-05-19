import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/config/tokens.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../data/ai_summaries_repository.dart';

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
                      _MarkdownBody(content: summary.content),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                const _ActionBar(),
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
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
                letterSpacing: -0.01 * 17,
                height: 1.3,
              ),
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
                style: TextStyle(fontSize: 13, color: c.border, height: 1),
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(items[i].icon, size: 12, color: c.textTertiary),
                const SizedBox(width: 4),
                Text(
                  items[i].text,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: c.textTertiary,
                    height: 1.3,
                  ),
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

// ---------------------------------------------------------------------------
// Markdown body (simple inline parser, no extra deps).
// ---------------------------------------------------------------------------

class _MarkdownBody extends StatelessWidget {
  const _MarkdownBody({required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    final blocks = _parseBlocks(content);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < blocks.length; i++)
          _MdBlockView(block: blocks[i], first: i == 0),
      ],
    );
  }
}

enum _MdBlockKind { heading, paragraph, bullets, numbered }

class _MdBlock {
  const _MdBlock({
    required this.kind,
    this.headingLevel = 0,
    this.text = '',
    this.items = const <String>[],
  });

  final _MdBlockKind kind;
  final int headingLevel;
  final String text;
  final List<String> items;
}

List<_MdBlock> _parseBlocks(String src) {
  final blocks = <_MdBlock>[];
  final lines = src.replaceAll('\r\n', '\n').split('\n');

  var i = 0;
  while (i < lines.length) {
    final line = lines[i];
    final trimmed = line.trim();

    if (trimmed.isEmpty) {
      i++;
      continue;
    }

    final headingMatch = RegExp(r'^(#{1,6})\s+(.*)$').firstMatch(trimmed);
    if (headingMatch != null) {
      blocks.add(_MdBlock(
        kind: _MdBlockKind.heading,
        headingLevel: headingMatch.group(1)!.length,
        text: headingMatch.group(2)!.trim(),
      ));
      i++;
      continue;
    }

    if (trimmed.startsWith('- ') ||
        trimmed.startsWith('* ') ||
        trimmed.startsWith('• ')) {
      final items = <String>[];
      while (i < lines.length) {
        final t = lines[i].trim();
        if (t.startsWith('- ') ||
            t.startsWith('* ') ||
            t.startsWith('• ')) {
          items.add(t.substring(2).trim());
          i++;
        } else {
          break;
        }
      }
      blocks.add(_MdBlock(kind: _MdBlockKind.bullets, items: items));
      continue;
    }

    final numMatch = RegExp(r'^\d+\.\s+(.*)$').firstMatch(trimmed);
    if (numMatch != null) {
      final items = <String>[];
      while (i < lines.length) {
        final t = lines[i].trim();
        final m = RegExp(r'^\d+\.\s+(.*)$').firstMatch(t);
        if (m != null) {
          items.add(m.group(1)!.trim());
          i++;
        } else {
          break;
        }
      }
      blocks.add(_MdBlock(kind: _MdBlockKind.numbered, items: items));
      continue;
    }

    // Paragraph: collect consecutive non-empty lines.
    final paragraphLines = <String>[trimmed];
    i++;
    while (i < lines.length && lines[i].trim().isNotEmpty) {
      final next = lines[i].trim();
      // Stop if a new block kind starts.
      if (RegExp(r'^(#{1,6})\s+').hasMatch(next) ||
          next.startsWith('- ') ||
          next.startsWith('* ') ||
          next.startsWith('• ') ||
          RegExp(r'^\d+\.\s+').hasMatch(next)) {
        break;
      }
      paragraphLines.add(next);
      i++;
    }
    blocks.add(_MdBlock(
      kind: _MdBlockKind.paragraph,
      text: paragraphLines.join(' '),
    ));
  }

  return blocks;
}

class _MdBlockView extends StatelessWidget {
  const _MdBlockView({required this.block, required this.first});

  final _MdBlock block;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    switch (block.kind) {
      case _MdBlockKind.heading:
        return _Heading(
          text: block.text,
          level: block.headingLevel,
          first: first,
        );
      case _MdBlockKind.paragraph:
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text.rich(
            TextSpan(children: _inlineSpans(block.text, c)),
            style: TextStyle(
              fontSize: 14,
              color: c.textSecondary,
              height: 1.65,
            ),
          ),
        );
      case _MdBlockKind.bullets:
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < block.items.length; i++) ...[
                if (i > 0) const SizedBox(height: 7),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 7.5, right: 8),
                      decoration: BoxDecoration(
                        color: c.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(children: _inlineSpans(block.items[i], c)),
                        style: TextStyle(
                          fontSize: 14,
                          color: c.textSecondary,
                          height: 1.55,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      case _MdBlockKind.numbered:
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < block.items.length; i++) ...[
                if (i > 0) const SizedBox(height: 7),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.only(top: 2, right: 10),
                      decoration: BoxDecoration(
                        color: c.accent.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: c.accent,
                          height: 1,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(children: _inlineSpans(block.items[i], c)),
                        style: TextStyle(
                          fontSize: 14,
                          color: c.textSecondary,
                          height: 1.55,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
    }
  }
}

class _Heading extends StatelessWidget {
  const _Heading({
    required this.text,
    required this.level,
    required this.first,
  });

  final String text;
  final int level;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    // H1/H2 with bottom border (matches design); H3+ inline.
    if (level <= 2) {
      return Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: first ? 0 : 20, bottom: 8),
        padding: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: c.border, width: 1)),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
            letterSpacing: -0.01 * 15,
            height: 1.3,
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.only(top: first ? 0 : 12, bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: c.textPrimary,
          height: 1.3,
        ),
      ),
    );
  }
}

/// Минимальный inline-парсер: `**bold**`, `*italic*`, `` `code` ``.
/// Всё остальное идёт обычным текстом.
List<TextSpan> _inlineSpans(String text, HFColors c) {
  final spans = <TextSpan>[];
  final pattern = RegExp(r'(\*\*[^*]+\*\*|\*[^*]+\*|`[^`]+`)');
  var pos = 0;
  for (final match in pattern.allMatches(text)) {
    if (match.start > pos) {
      spans.add(TextSpan(text: text.substring(pos, match.start)));
    }
    final token = match.group(0)!;
    if (token.startsWith('**')) {
      spans.add(TextSpan(
        text: token.substring(2, token.length - 2),
        style: TextStyle(
          color: c.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ));
    } else if (token.startsWith('`')) {
      spans.add(TextSpan(
        text: token.substring(1, token.length - 1),
        style: TextStyle(
          color: c.accent,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ));
    } else {
      spans.add(TextSpan(
        text: token.substring(1, token.length - 1),
        style: const TextStyle(fontStyle: FontStyle.italic),
      ));
    }
    pos = match.end;
  }
  if (pos < text.length) {
    spans.add(TextSpan(text: text.substring(pos)));
  }
  return spans;
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
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar();

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
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
                onTap: () {},
                borderRadius: BorderRadius.circular(HFTokens.rMd),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: c.accent,
                    borderRadius: BorderRadius.circular(HFTokens.rMd),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('💬', style: TextStyle(fontSize: 16, height: 1)),
                      const SizedBox(width: 7),
                      Text(
                        AppLocalizations.of(context).aiSummaryAsk,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.2,
                        ),
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
              onTap: () {},
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
                    const Text('🔄', style: TextStyle(fontSize: 16, height: 1)),
                    const SizedBox(width: 7),
                    Text(
                      AppLocalizations.of(context).aiSummaryRegenerate,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: c.textSecondary,
                        height: 1.2,
                      ),
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
