import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/config/tokens.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../shared/widgets/hf_button.dart';
import '../../../shared/widgets/hf_header_bar.dart';
import '../../../shared/widgets/hf_input.dart';
import '../../journal/data/journal_template_provider.dart';

/// Шаблон рефлексии — список вопросов в дневнике (SPEC §10.2).
/// 4 дефолтных вопроса, можно редактировать, добавлять, сбросить.
class ReflectionTemplateScreen extends ConsumerStatefulWidget {
  const ReflectionTemplateScreen({super.key});

  @override
  ConsumerState<ReflectionTemplateScreen> createState() =>
      _ReflectionTemplateScreenState();
}

class _ReflectionTemplateScreenState
    extends ConsumerState<ReflectionTemplateScreen> {
  List<TextEditingController> _ctrls = [];
  bool _initialized = false;

  List<String> _defaults(AppLocalizations l) => [
        l.reflectionTemplateQ1,
        l.reflectionTemplateQ2,
        l.reflectionTemplateQ3,
        l.reflectionTemplateQ4,
      ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final l = AppLocalizations.of(context);
      // Seed from saved template if any, otherwise from ARB defaults.
      final saved = ref.read(journalTemplateProvider);
      final seed = (saved == null || saved.isEmpty) ? _defaults(l) : saved;
      _ctrls = [
        for (final q in seed) TextEditingController(text: q),
      ];
      _initialized = true;
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _addQuestion() {
    setState(() => _ctrls.add(TextEditingController()));
  }

  void _removeQuestion(int i) {
    setState(() {
      _ctrls[i].dispose();
      _ctrls.removeAt(i);
    });
  }

  void _resetToDefaults() {
    final l = AppLocalizations.of(context);
    setState(() {
      for (final c in _ctrls) {
        c.dispose();
      }
      _ctrls = [
        for (final q in _defaults(l)) TextEditingController(text: q),
      ];
    });
    ref.read(journalTemplateProvider.notifier).reset();
  }

  Future<void> _saveAndClose() async {
    final questions = _ctrls.map((c) => c.text).toList(growable: false);
    await ref.read(journalTemplateProvider.notifier).save(questions);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: c.bgSecondary,
      body: Column(
        children: [
          HFHeaderBar(
            title: l.reflectionTemplateTitle,
            onBack: _saveAndClose,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                  child: Text(
                    l.reflectionTemplateDesc,
                    style: TextStyle(
                      fontSize: 13,
                      color: c.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
                for (var i = 0; i < _ctrls.length; i++) ...[
                  _QuestionRow(
                    index: i,
                    controller: _ctrls[i],
                    canRemove: _ctrls.length > 1,
                    onRemove: () => _removeQuestion(i),
                  ),
                  const SizedBox(height: 10),
                ],
                if (_ctrls.length < 8)
                  HFButton(
                    label: l.reflectionTemplateAddButton,
                    icon: LucideIcons.plus,
                    variant: HFButtonVariant.secondary,
                    onPressed: _addQuestion,
                    fullWidth: true,
                  ),
                const SizedBox(height: 12),
                HFButton(
                  label: l.reflectionTemplateResetButton,
                  variant: HFButtonVariant.ghost,
                  onPressed: _resetToDefaults,
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionRow extends StatelessWidget {
  const _QuestionRow({
    required this.index,
    required this.controller,
    required this.canRemove,
    required this.onRemove,
  });

  final int index;
  final TextEditingController controller;
  final bool canRemove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(HFTokens.rLg),
        border: Border.all(color: c.border, width: 1),
        boxShadow: HFTokens.cardShadow(c.shadow),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.accent.withValues(alpha: 0.12),
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: c.accent,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: HFInput(
              controller: controller,
              hint: l.reflectionTemplateInputHint,
            ),
          ),
          if (canRemove)
            IconButton(
              onPressed: onRemove,
              icon: Icon(LucideIcons.x, size: 18, color: c.textTertiary),
              tooltip: l.commonDelete,
            ),
        ],
      ),
    );
  }
}
