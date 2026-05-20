import 'package:flutter/material.dart';
import 'package:habit_flow/core/config/text_theme.dart';
import 'package:habit_flow/core/config/tokens.dart';

/// Упрощённый Markdown-парсер без внешних зависимостей.
/// Поддерживает: H1-H6, списки (буллеты и нумерованные), абзацы с inline
/// `**bold**`, `*italic*` и `` `code` ``.
class HfMarkdown extends StatelessWidget {
  const HfMarkdown({
    super.key,
    required this.content,
    this.textColor,
  });

  final String content;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final blocks = _parseBlocks(content);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < blocks.length; i++)
          _MdBlockView(
            block: blocks[i],
            first: i == 0,
            textColor: textColor,
          ),
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
  const _MdBlockView({
    required this.block,
    required this.first,
    this.textColor,
  });

  final _MdBlock block;
  final bool first;
  final Color? textColor;

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
            TextSpan(children: _inlineSpans(block.text, c, context.tt, textColor)),
            style: context.tt.bodyMedium!.copyWith(
              color: textColor ?? c.textSecondary,
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
                        TextSpan(children: _inlineSpans(block.items[i], c, context.tt, textColor)),
                        style: context.tt.bodyMedium!.copyWith(
                          color: textColor ?? c.textSecondary,
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
                        style: context.tt.labelSmall!.copyWith(color: c.accent, height: 1),
                      ),
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(children: _inlineSpans(block.items[i], c, context.tt, textColor)),
                        style: context.tt.bodyMedium!.copyWith(
                          color: textColor ?? c.textSecondary,
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
          style: context.tt.titleMedium!.copyWith(
            color: c.textPrimary,
            height: 1.3,
            letterSpacing: -0.01 * 15,
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.only(top: first ? 0 : 12, bottom: 6),
      child: Text(
        text,
        style: context.tt.labelLarge!.copyWith(color: c.textPrimary, height: 1.3),
      ),
    );
  }
}

List<TextSpan> _inlineSpans(String text, HFColors c, TextTheme tt, Color? defaultTextColor) {
  final spans = <TextSpan>[];
  final pattern = RegExp(r'(\*\*[^*]+\*\*|\*[^*]+\*|`[^`]+`)');
  var pos = 0;
  for (final match in pattern.allMatches(text)) {
    if (match.start > pos) {
      spans.add(TextSpan(
        text: text.substring(pos, match.start),
        style: defaultTextColor != null ? TextStyle(color: defaultTextColor) : null,
      ));
    }
    final token = match.group(0)!;
    if (token.startsWith('**')) {
      spans.add(TextSpan(
        text: token.substring(2, token.length - 2),
        style: tt.labelLarge!.copyWith(color: defaultTextColor ?? c.textPrimary),
      ));
    } else if (token.startsWith('`')) {
      spans.add(TextSpan(
        text: token.substring(1, token.length - 1),
        style: tt.bodyMedium!.copyWith(color: c.accent),
      ));
    } else {
      spans.add(TextSpan(
        text: token.substring(1, token.length - 1),
        style: tt.bodyMedium!.copyWith(
          fontStyle: FontStyle.italic,
          color: defaultTextColor,
        ),
      ));
    }
    pos = match.end;
  }
  if (pos < text.length) {
    spans.add(TextSpan(
      text: text.substring(pos),
      style: defaultTextColor != null ? TextStyle(color: defaultTextColor) : null,
    ));
  }
  return spans;
}
