import 'package:habit_flow/core/config/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/config/tokens.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../shared/widgets/hf_input.dart';
import '../data/ai_prompts_repository.dart';
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

  _Cat? _activeFilter;

  void _runPrompt(AiPrompt p) {
    final question = '${p.title}. ${p.description}';
    ref.read(pendingPromptProvider.notifier).state = question;
    ref.read(aiActiveTabProvider.notifier).state = 0;
  }

  List<AiPrompt> _getLocalizedSystemPrompts(AppLocalizations l) {
    return [
      AiPrompt(
        id: 'sys-1',
        userId: '',
        emoji: '📊',
        title: l.aiPromptSystem1Title,
        description: l.aiPromptSystem1Desc,
        category: 'analysis',
        isSystem: true,
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      ),
      AiPrompt(
        id: 'sys-2',
        userId: '',
        emoji: '🔍',
        title: l.aiPromptSystem2Title,
        description: l.aiPromptSystem2Desc,
        category: 'analysis',
        isSystem: true,
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      ),
      AiPrompt(
        id: 'sys-3',
        userId: '',
        emoji: '⚠️',
        title: l.aiPromptSystem3Title,
        description: l.aiPromptSystem3Desc,
        category: 'relapse',
        isSystem: true,
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      ),
      AiPrompt(
        id: 'sys-4',
        userId: '',
        emoji: '🎯',
        title: l.aiPromptSystem4Title,
        description: l.aiPromptSystem4Desc,
        category: 'growth',
        isSystem: true,
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      ),
      AiPrompt(
        id: 'sys-5',
        userId: '',
        emoji: '💭',
        title: l.aiPromptSystem5Title,
        description: l.aiPromptSystem5Desc,
        category: 'emotions',
        isSystem: true,
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      ),
      AiPrompt(
        id: 'sys-6',
        userId: '',
        emoji: '🔗',
        title: l.aiPromptSystem6Title,
        description: l.aiPromptSystem6Desc,
        category: 'analysis',
        isSystem: true,
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      ),
      AiPrompt(
        id: 'sys-7',
        userId: '',
        emoji: '🌱',
        title: l.aiPromptSystem7Title,
        description: l.aiPromptSystem7Desc,
        category: 'growth',
        isSystem: true,
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      ),
      AiPrompt(
        id: 'sys-8',
        userId: '',
        emoji: '🛑',
        title: l.aiPromptSystem8Title,
        description: l.aiPromptSystem8Desc,
        category: 'analysis',
        isSystem: true,
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      ),
      AiPrompt(
        id: 'sys-9',
        userId: '',
        emoji: '⚙️',
        title: l.aiPromptSystem9Title,
        description: l.aiPromptSystem9Desc,
        category: 'growth',
        isSystem: true,
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      ),
      AiPrompt(
        id: 'sys-10',
        userId: '',
        emoji: '🎭',
        title: l.aiPromptSystem10Title,
        description: l.aiPromptSystem10Desc,
        category: 'emotions',
        isSystem: true,
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      ),
      AiPrompt(
        id: 'sys-11',
        userId: '',
        emoji: '🔥',
        title: l.aiPromptSystem11Title,
        description: l.aiPromptSystem11Desc,
        category: 'analysis',
        isSystem: true,
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      ),
      AiPrompt(
        id: 'sys-12',
        userId: '',
        emoji: '💔',
        title: l.aiPromptSystem12Title,
        description: l.aiPromptSystem12Desc,
        category: 'relapse',
        isSystem: true,
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      ),
      AiPrompt(
        id: 'sys-13',
        userId: '',
        emoji: '📅',
        title: l.aiPromptSystem13Title,
        description: l.aiPromptSystem13Desc,
        category: 'growth',
        isSystem: true,
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      ),
      AiPrompt(
        id: 'sys-14',
        userId: '',
        emoji: '🤝',
        title: l.aiPromptSystem14Title,
        description: l.aiPromptSystem14Desc,
        category: 'emotions',
        isSystem: true,
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      ),
    ];
  }

  void _showCreatePromptDialog(BuildContext context, AppLocalizations l, HFColors c) {
    final emojiCtrl = TextEditingController(text: '💬');
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    _Cat selectedCat = _Cat.analysis;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (stateContext, setDialogState) {
            return AlertDialog(
              backgroundColor: c.card,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                l.aiPromptCreateTitle,
                style: dialogContext.tt.titleLarge!.copyWith(color: c.textPrimary),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    HFInput(
                      controller: emojiCtrl,
                      label: l.aiPromptCreateEmoji,
                      hint: '💬',
                    ),
                    const SizedBox(height: 12),
                    HFInput(
                      controller: titleCtrl,
                      label: l.aiPromptCreateTitleLabel,
                      hint: 'e.g. My custom prompt',
                    ),
                    const SizedBox(height: 12),
                    HFInput(
                      controller: descCtrl,
                      label: l.aiPromptCreateDescLabel,
                      hint: 'e.g. Detailed question for AI',
                      minLines: 2,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l.aiPromptCreateCategoryLabel,
                      style: dialogContext.tt.labelMedium!.copyWith(color: c.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: c.card,
                        borderRadius: BorderRadius.circular(HFTokens.rMd),
                        border: Border.all(color: c.border, width: 1.5),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<_Cat>(
                          value: selectedCat,
                          dropdownColor: c.card,
                          isExpanded: true,
                          style: dialogContext.tt.bodyMedium!.copyWith(color: c.textPrimary),
                          items: _Cat.values.map((cat) {
                            return DropdownMenuItem<_Cat>(
                              value: cat,
                              child: Text(_labelForCat(l, cat)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                selectedCat = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(l.commonCancel, style: TextStyle(color: c.textTertiary)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final emoji = emojiCtrl.text.trim();
                    final title = titleCtrl.text.trim();
                    final desc = descCtrl.text.trim();
                    if (title.isEmpty || desc.isEmpty) return;

                    await ref.read(aiPromptsRepositoryProvider).createPrompt(
                      emoji: emoji.isEmpty ? '💬' : emoji,
                      title: title,
                      description: desc,
                      category: _serializeCat(selectedCat),
                    );

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(l.commonSave),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);

    final customPromptsAsync = ref.watch(customPromptsStreamProvider);
    final customPrompts = customPromptsAsync.valueOrNull ?? [];
    final systemPrompts = _getLocalizedSystemPrompts(l);

    final allPrompts = [...customPrompts, ...systemPrompts];

    final filtered = _activeFilter == null
        ? allPrompts
        : allPrompts.where((p) => _parseCat(p.category) == _activeFilter).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ColoredBox(
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
                          label: _labelForCat(l, _filterKinds[i]),
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
                    key: ValueKey(filtered[i].id),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePromptDialog(context, l, c),
        backgroundColor: c.accent,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(LucideIcons.plus, size: 24),
      ),
    );
  }
}

class _PromptCard extends ConsumerStatefulWidget {
  const _PromptCard({
    super.key,
    required this.prompt,
    required this.onTap,
  });

  final AiPrompt prompt;
  final VoidCallback onTap;

  @override
  ConsumerState<_PromptCard> createState() => _PromptCardState();
}

class _PromptCardState extends ConsumerState<_PromptCard> {
  bool _pressed = false;
  bool _isDeleting = false;

  Future<void> _confirmAndDeletePrompt(BuildContext context) async {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l.aiPromptDeleteConfirmTitle,
          style: ctx.tt.titleMedium!.copyWith(color: c.textPrimary),
        ),
        content: Text(
          l.aiPromptDeleteConfirmText,
          style: ctx.tt.bodyMedium!.copyWith(color: c.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.commonCancel, style: TextStyle(color: c.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l.commonDelete,
              style: TextStyle(color: c.danger, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await ref.read(aiPromptsRepositoryProvider).deletePrompt(widget.prompt.id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: c.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final cat = _parseCat(widget.prompt.category);
    final catColor = _catColor(c, cat);
    final catLabel = _labelForCat(l, cat);

    return Stack(
      children: [
        GestureDetector(
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.tt.labelLarge!.copyWith(color: c.textPrimary, height: 1.25),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Text(
                      widget.prompt.description,
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
        ),
        if (!widget.prompt.isSystem)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: _isDeleting ? null : () => _confirmAndDeletePrompt(context),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: c.bgSecondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: c.border),
                ),
                child: _isDeleting
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.grey),
                        ),
                      )
                    : Icon(
                        LucideIcons.trash2,
                        size: 14,
                        color: c.textTertiary,
                      ),
              ),
            ),
          ),
      ],
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

Color _catColor(HFColors c, _Cat? cat) {
  switch (cat) {
    case _Cat.analysis:
      return c.accent;
    case _Cat.relapse:
      return c.danger;
    case _Cat.growth:
      return c.success;
    case _Cat.emotions:
      return c.premium;
    case null:
      return c.textTertiary;
  }
}

String _labelForCat(AppLocalizations l, _Cat? kind) {
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

_Cat? _parseCat(String category) {
  switch (category) {
    case 'analysis':
      return _Cat.analysis;
    case 'emotions':
      return _Cat.emotions;
    case 'growth':
      return _Cat.growth;
    case 'relapse':
      return _Cat.relapse;
    default:
      return null;
  }
}

String _serializeCat(_Cat cat) {
  switch (cat) {
    case _Cat.analysis:
      return 'analysis';
    case _Cat.emotions:
      return 'emotions';
    case _Cat.growth:
      return 'growth';
    case _Cat.relapse:
      return 'relapse';
  }
}

enum _Cat {
  analysis,
  emotions,
  growth,
  relapse,
}
