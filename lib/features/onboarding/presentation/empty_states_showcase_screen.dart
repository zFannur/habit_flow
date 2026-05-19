import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/config/tokens.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../shared/widgets/hf_button.dart';
import '../../../shared/widgets/hf_empty_state.dart';
import '../../../shared/widgets/hf_section_label.dart';

/// Dev-only витрина пустых состояний (см. docs/design/empty-states.html).
class EmptyStatesShowcaseScreen extends StatelessWidget {
  const EmptyStatesShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: c.bgSecondary,
      appBar: AppBar(
        title: const Text('Empty States'),
        backgroundColor: c.bgPrimary,
        foregroundColor: c.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: Border(bottom: BorderSide(color: c.border)),
      ),
      body: ListView(
        children: [
          const HFSectionLabel(label: 'EMPTY · 01 Нет привычек'),
          _Frame(
            child: HFEmptyState(
              emoji: '🌱',
              title: l.emptyTitleNoHabits,
              description: l.emptyDescNoHabits,
              action: HFButton(
                label: l.commonCreateHabit,
                icon: LucideIcons.plus,
                onPressed: () {},
              ),
            ),
          ),
          const HFSectionLabel(label: 'EMPTY · 02 Нет записей дневника'),
          _Frame(
            child: HFEmptyState(
              emoji: '📓',
              title: l.emptyTitleNoEntries,
              description: l.emptyDescNoEntries,
              action: HFButton(
                label: l.emptyActionNoEntries,
                onPressed: () {},
              ),
            ),
          ),
          const HFSectionLabel(label: 'EMPTY · 03 Нет ИИ-сводок'),
          _Frame(
            child: HFEmptyState(
              emoji: '✨',
              title: l.emptyTitleNoSummaries,
              description: l.emptyDescNoSummaries(4),
              action: const _AiSummaryProgressAction(value: 4, max: 30),
              secondaryAction: HFButton(
                label: l.emptyActionNoSummaries,
                onPressed: () {},
              ),
            ),
          ),
          const HFSectionLabel(label: 'EMPTY · 04 ИИ без ключа'),
          _Frame(
            child: HFEmptyState(
              emoji: '🔑',
              title: l.emptyTitleNoKey,
              description: l.emptyDescNoKey,
              action: HFButton(
                label: l.commonOpenSettings,
                onPressed: () {},
              ),
            ),
          ),
          const HFSectionLabel(label: 'ERROR · 08 Нет интернета'),
          _Frame(
            child: HFEmptyState(
              emoji: '📡',
              title: l.emptyTitleNoInternet,
              description: l.emptyDescNoInternet,
              action: HFButton(
                label: l.commonRetry,
                variant: HFButtonVariant.secondary,
                onPressed: () {},
              ),
            ),
          ),
          const HFSectionLabel(label: 'ERROR · 09 ИИ-лимит'),
          _Frame(
            child: HFEmptyState(
              emoji: '⏳',
              title: l.emptyTitleAiLimit,
              description: l.emptyDescAiLimit,
              action: _CountdownPill(text: l.emptyAiLimitCountdown(4, 23)),
              secondaryAction: HFButton(
                label: l.emptyAiLimitUpgrade,
                onPressed: () {},
              ),
            ),
          ),
          const HFSectionLabel(label: 'ERROR · 10 Неверный ключ'),
          _Frame(
            child: HFEmptyState(
              emoji: '🔑',
              title: l.emptyTitleBadKey,
              description: l.emptyDescBadKey,
              action: HFButton(
                label: l.emptyActionBadKey,
                variant: HFButtonVariant.danger,
                onPressed: () {},
              ),
            ),
          ),
          const HFSectionLabel(label: 'SUCCESS · 11 Все привычки выполнены'),
          _Frame(
            child: HFEmptyState(
              emoji: '🎉',
              title: l.emptyTitleAllDone,
              action: const _SuccessScorePill(done: 5, total: 5),
              secondaryAction: const _QuoteOfDay(
                quote: '«Каждое действие — голос за того, кем ты становишься.»',
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _Frame extends StatelessWidget {
  const _Frame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      width: double.infinity,
      height: 500,
      decoration: BoxDecoration(
        color: c.bgPrimary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
            color: c.shadow,
            offset: const Offset(0, 4),
            blurRadius: 24,
          ),
          BoxShadow(
            color: c.shadow,
            offset: const Offset(0, 1),
            blurRadius: 4,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Center(child: child),
    );
  }
}

class _AiSummaryProgressAction extends StatelessWidget {
  const _AiSummaryProgressAction({required this.value, required this.max});

  final int value;
  final int max;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final pct = ((value / max) * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: SizedBox(
            height: 6,
            child: Stack(
              children: [
                Container(color: c.bgTertiary),
                FractionallySizedBox(
                  widthFactor: value / max,
                  child: Container(color: c.accent),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$value из $max',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: c.textTertiary,
              ),
            ),
            Text(
              '$pct%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: c.accent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CountdownPill extends StatelessWidget {
  const _CountdownPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: c.danger.withValues(alpha: 0.06),
        border: Border.all(color: c.danger.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(HFTokens.rFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.clock, size: 14, color: c.danger),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: c.danger,
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessScorePill extends StatelessWidget {
  const _SuccessScorePill({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: c.success.withValues(alpha: 0.1),
        border: Border.all(color: c.success.withValues(alpha: 0.25), width: 1.5),
        borderRadius: BorderRadius.circular(HFTokens.rFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.checkCircle2, size: 16, color: c.success),
          const SizedBox(width: 6),
          Text(
            '$done из $total',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: c.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuoteOfDay extends StatelessWidget {
  const _QuoteOfDay({required this.quote});

  final String quote;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: c.bgSecondary,
          border: Border.all(color: c.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.quoteOfDayLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.06 * 11,
                color: c.textTertiary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              quote,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                height: 1.6,
                fontStyle: FontStyle.italic,
                color: c.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
