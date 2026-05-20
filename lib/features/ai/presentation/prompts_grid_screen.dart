import 'package:habit_flow/core/config/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/tokens.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../data/chat_providers.dart';

class PromptsGridScreen extends ConsumerStatefulWidget {
  const PromptsGridScreen({super.key});

  @override
  ConsumerState<PromptsGridScreen> createState() => _PromptsGridScreenState();
}

class _PromptsGridScreenState extends ConsumerState<PromptsGridScreen> {
  static const _filterKinds = <_Cat?>[
    null,
    _Cat.analysis,
    _Cat.emotions,
    _Cat.growth,
    _Cat.relapse,
  ];

  static const _prompts = <_Prompt>[
    _Prompt(1, '📊', 'Анализ паттернов', 'Что повторяется в моём поведении', _Cat.analysis),
    _Prompt(2, '🔍', 'Слепые пятна', 'Что я мог упустить', _Cat.analysis),
    _Prompt(3, '⚠️', 'Риски срыва', 'Какие привычки в опасности', _Cat.relapse),
    _Prompt(4, '🎯', 'Следующая цель', 'Какую привычку добавить', _Cat.growth),
    _Prompt(5, '💭', 'Эмоц. погода', 'Динамика настроения', _Cat.emotions),
    _Prompt(6, '🔗', 'Корреляции', 'Связи между привычками и эмоциями', _Cat.analysis),
    _Prompt(7, '🌱', 'Рост', 'Я сегодня vs месяц назад', _Cat.growth),
    _Prompt(8, '🛑', 'Что убрать', 'Какие привычки не работают', _Cat.analysis),
    _Prompt(9, '⚙️', 'Оптимизация дня', 'Как реструктурировать день', _Cat.growth),
    _Prompt(10, '🎭', 'Identity check', 'Соответствую ли я своим ценностям', _Cat.emotions),
    _Prompt(11, '🔥', 'Стрики', 'Какой streak настоящий прогресс', _Cat.analysis),
    _Prompt(12, '💔', 'Триггеры срыва', 'Что вызывает пропуски', _Cat.relapse),
    _Prompt(13, '📅', 'Ритуал недели', 'Якорь из сильных привычек', _Cat.growth),
    _Prompt(14, '🤝', 'Письмо себе', 'Письмо в роли близкого друга', _Cat.emotions),
  ];

  _Cat? _activeFilter;

  /// Hands the chosen prompt off to chat: writes the question into
  /// [pendingPromptProvider] (which the chat screen consumes & auto-sends)
  /// and switches the AI tab back to "Chat".
  void _runPrompt(_Prompt p) {
    final question = '${p.title}. ${p.desc}';
    ref.read(pendingPromptProvider.notifier).state = question;
    ref.read(aiActiveTabProvider.notifier).state = 0;
  }

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final filtered = _activeFilter == null
        ? _prompts
        : _prompts.where((p) => p.cat == _activeFilter).toList();

    String labelFor(_Cat? kind) {
      if (kind == null) return l.aiPromptsFilterAll;
      switch (kind) {
        case _Cat.analysis:
          return l.aiPromptsFilterAnalysis;
        case _Cat.emotions:
          return l.aiPromptsFilterEmotions;
        case _Cat.growth:
          return l.aiPromptsFilterGrowth;
        case _Cat.relapse:
          return l.aiPromptsFilterRelapse;
      }
    }

    return ColoredBox(
      color: c.bgSecondary,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Text(
                l.aiPromptsIntro,
                style: context.tt.bodyMedium!.copyWith(color: c.textSecondary, height: 1.55, fontSize: 13.5),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 14, 0, 14),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    for (var i = 0; i < _filterKinds.length; i++) ...[
                      _FilterChip(
                        label: labelFor(_filterKinds[i]),
                        selected: _activeFilter == _filterKinds[i],
                        onTap: () =>
                            setState(() => _activeFilter = _filterKinds[i]),
                      ),
                      if (i != _filterKinds.length - 1)
                        const SizedBox(width: 7),
                    ],
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                mainAxisExtent: 152,
              ),
              delegate: SliverChildBuilderDelegate(
                (_, i) => _PromptCard(
                  prompt: filtered[i],
                  onTap: () => _runPrompt(filtered[i]),
                ),
                childCount: filtered.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 18, 12, 24),
              child: Center(
                child: Text(
                  l.aiPromptsCount(filtered.length),
                  style: context.tt.bodySmall!.copyWith(color: c.textTertiary, fontSize: 12.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromptCard extends StatefulWidget {
  const _PromptCard({required this.prompt, required this.onTap});

  final _Prompt prompt;
  final VoidCallback onTap;

  @override
  State<_PromptCard> createState() => _PromptCardState();
}

class _PromptCardState extends State<_PromptCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final cat = widget.prompt.cat;
    final catColor = _catColor(c, cat);
    final catLabel = switch (cat) {
      _Cat.analysis => l.aiPromptsFilterAnalysis,
      _Cat.emotions => l.aiPromptsFilterEmotions,
      _Cat.growth => l.aiPromptsFilterGrowth,
      _Cat.relapse => l.aiPromptsFilterRelapse,
    };

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.fromLTRB(13, 14, 13, 12),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(HFTokens.rLg),
            border: Border.all(color: c.border),
            boxShadow: _pressed ? const [] : HFTokens.cardShadow(c.shadow),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.prompt.emoji,
                style: context.tt.headlineLarge!.copyWith(height: 1),
              ),
              const SizedBox(height: 8),
              Text(
                widget.prompt.title,
                style: context.tt.labelLarge!.copyWith(color: c.textPrimary, height: 1.25),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  widget.prompt.desc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.tt.bodyMedium!.copyWith(color: c.textSecondary, height: 1.35, fontSize: 11.5),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                catLabel.toUpperCase(),
                style: context.tt.bodyMedium!.copyWith(color: catColor, letterSpacing: 0.02 * 10.5, fontWeight: FontWeight.w700, fontSize: 10.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? c.accent.withValues(alpha: 0.1) : c.card,
          borderRadius: BorderRadius.circular(HFTokens.rFull),
          border: Border.all(
            color: selected ? c.accent : c.border,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: context.tt.bodySmall!.copyWith(color: selected ? c.accent : c.textSecondary, height: 1.2),
        ),
      ),
    );
  }
}

Color _catColor(HFColors c, _Cat cat) {
  switch (cat) {
    case _Cat.analysis:
      return c.accent;
    case _Cat.relapse:
      return c.danger;
    case _Cat.growth:
      return c.success;
    case _Cat.emotions:
      return c.premium;
  }
}

enum _Cat {
  analysis('Анализ'),
  relapse('Срывы'),
  growth('Рост'),
  emotions('Эмоции');

  const _Cat(this.label);
  final String label;
}

class _Prompt {
  const _Prompt(this.id, this.emoji, this.title, this.desc, this.cat);
  final int id;
  final String emoji;
  final String title;
  final String desc;
  final _Cat cat;
}
