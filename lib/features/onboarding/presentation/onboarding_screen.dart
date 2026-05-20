import 'package:habit_flow/core/config/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/tokens.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/services/locale_service.dart';
import '../../../core/services/onboarding_service.dart';
import '../data/onboarding_repository.dart';

/// Onboarding flow (см. docs/design/onboarding.html). 5 слайдов c пагинацией:
/// Welcome → Identity → Choose path → Templates grid → Notifications.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _total = 5;

  final _controller = PageController();
  int _step = 0;
  String _lang = 'ru';
  final Set<int> _selectedTemplates = <int>{};
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int n) {
    if (n < 0 || n >= _total) return;
    _controller.animateToPage(
      n,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _next() async {
    // Step 0 (Welcome) → also commit selected language.
    if (_step == 0) {
      await ref.read(localeProvider.notifier).set(_lang);
    }

    // Step 3 (Templates) → create selected habits.
    if (_step == 3 && _selectedTemplates.isNotEmpty && !_submitting) {
      setState(() => _submitting = true);
      try {
        final templates = _selectedTemplates
            .map((i) => kOnboardingTemplates[i])
            .toList(growable: false);
        await ref
            .read(onboardingRepositoryProvider)
            .createFromTemplates(templates);
      } finally {
        if (mounted) setState(() => _submitting = false);
      }
    }

    if (_step < _total - 1) {
      _goTo(_step + 1);
      return;
    }

    // Final step → mark onboarding seen + go to /today.
    await ref.read(markOnboardingSeenProvider)();
    if (mounted) context.go('/today');
  }

  void _toggleTemplate(int i) {
    setState(() {
      if (_selectedTemplates.contains(i)) {
        _selectedTemplates.remove(i);
      } else if (_selectedTemplates.length < 3) {
        _selectedTemplates.add(i);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: c.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              step: _step,
              total: _total,
              onBack: () => _goTo(_step - 1),
              onSkip: () => _goTo(_total - 1),
              skipLabel: l.onboardingSkip,
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _step = i),
                children: [
                  _Slide1(
                    lang: _lang,
                    onLangChanged: (lng) => setState(() => _lang = lng),
                    onBegin: _next,
                  ),
                  _Slide2(onNext: _next),
                  _Slide3(onNext: _next),
                  _Slide4(
                    lang: _lang,
                    selected: _selectedTemplates,
                    onToggle: _toggleTemplate,
                    onNext: _next,
                  ),
                  _Slide5(onFinish: _next),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── Top bar ───────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.step,
    required this.total,
    required this.onBack,
    required this.onSkip,
    required this.skipLabel,
  });

  final int step;
  final int total;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final String skipLabel;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final showSkip = step >= 1 && step <= 3;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: step > 0
                ? _BackButton(onTap: onBack)
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Center(
              child: _ProgressDots(total: total, current: step),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 60,
            child: Align(
              alignment: Alignment.centerRight,
              child: showSkip
                  ? GestureDetector(
                      onTap: onSkip,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          skipLabel,
                          style: context.tt.titleSmall!.copyWith(color: c.textTertiary, height: 1.2),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Material(
      color: c.card,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            border: Border.all(color: c.border, width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            '←',
            style: context.tt.titleLarge!.copyWith(color: c.textSecondary, height: 1),
          ),
        ),
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.total, required this.current});

  final int total;
  final int current;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final active = i == current;
        return Padding(
          padding: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            width: active ? 22 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: active ? c.accent : c.bgTertiary,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────── Primary CTA ───────────────────────────

/// Primary CTA из onboarding.html: padding 15×24, radius 14, font 16/700.
/// HFButton md имеет padding 12×24, radius 12, font 15/600 — не подходит.
class _PrimaryCta extends StatelessWidget {
  const _PrimaryCta({
    required this.label,
    required this.onPressed,
    this.disabled = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Opacity(
      opacity: disabled ? 0.35 : 1,
      child: Material(
        color: c.accent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
            alignment: Alignment.center,
            child: Text(
              label,
              style: context.tt.bodyLarge!.copyWith(color: Colors.white, height: 1.2, letterSpacing: -0.01 * 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── Slide 1: Welcome ───────────────────────────

class _Slide1 extends StatelessWidget {
  const _Slide1({
    required this.lang,
    required this.onLangChanged,
    required this.onBegin,
  });

  final String lang;
  final ValueChanged<String> onLangChanged;
  final VoidCallback onBegin;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: _LangChip(lang: lang, onChanged: onLangChanged),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '🌱',
                    style: context.tt.displayLarge!.copyWith(height: 1, fontSize: 80.0),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'HabitFlow',
                    textAlign: TextAlign.center,
                    style: context.tt.displayLarge!.copyWith(color: c.textPrimary, height: 1.1, letterSpacing: -0.03 * 34, fontSize: 34.0),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l.onboardingS1Sub,
                    textAlign: TextAlign.center,
                    style: context.tt.titleMedium!.copyWith(color: c.textSecondary, height: 1.5, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ),
          _PrimaryCta(label: l.onboardingBegin, onPressed: onBegin),
        ],
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  const _LangChip({required this.lang, required this.onChanged});

  final String lang;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.bgTertiary,
        border: Border.all(color: c.border, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LangOption(
            label: l.langRu,
            active: lang == 'ru',
            onTap: () => onChanged('ru'),
          ),
          _LangOption(
            label: l.langEn,
            active: lang == 'en',
            onTap: () => onChanged('en'),
          ),
        ],
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  const _LangOption({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final inner = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Text(
        label,
        style: context.tt.labelMedium!.copyWith(color: active ? c.accent : c.textSecondary, height: 1.2),
      ),
    );

    if (!active) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: inner,
      );
    }
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: c.card,
        borderRadius: BorderRadius.circular(8),
        elevation: 0,
        shadowColor: c.shadow,
        child: Container(
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: c.shadow, offset: const Offset(0, 1), blurRadius: 3),
            ],
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: inner,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── Slide 2: Identity ───────────────────────────

class _Slide2 extends StatelessWidget {
  const _Slide2({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: _IdentityCircles(
                centerLabel: l.onboardingS2LabelCenter,
                habitsLabel: l.onboardingS2LabelHabits,
                actionsLabel: l.onboardingS2LabelActions,
                identityLabel: l.onboardingS2LabelIdentity,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l.onboardingS2Title,
            style: context.tt.headlineMedium!.copyWith(color: c.textPrimary, height: 1.2, letterSpacing: -0.02 * 24, fontSize: 24.0),
          ),
          const SizedBox(height: 14),
          Text(
            l.onboardingS2P1,
            style: context.tt.bodyMedium!.copyWith(color: c.textSecondary, height: 1.65),
          ),
          const SizedBox(height: 10),
          Text(
            l.onboardingS2P2,
            style: context.tt.bodyMedium!.copyWith(color: c.textSecondary, height: 1.65),
          ),
          const SizedBox(height: 16),
          Opacity(
            opacity: 0.75,
            child: Container(
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: c.accent, width: 3)),
              ),
              padding: const EdgeInsets.only(left: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.onboardingS2Quote,
                    style: context.tt.bodySmall!.copyWith(color: c.textSecondary, height: 1.5, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.onboardingS2Author,
                    style: context.tt.labelSmall!.copyWith(color: c.textTertiary, height: 1.2),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _PrimaryCta(label: l.commonNext, onPressed: onNext),
        ],
      ),
    );
  }
}

class _IdentityCircles extends StatelessWidget {
  const _IdentityCircles({
    required this.centerLabel,
    required this.habitsLabel,
    required this.actionsLabel,
    required this.identityLabel,
  });

  final String centerLabel;
  final String habitsLabel;
  final String actionsLabel;
  final String identityLabel;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);

    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        children: [
          _ring(c.accent, 178, 0.18),
          _ring(c.accent, 140, 0.18),
          _ring(c.accent, 100, 0.18),
          _ring(c.accent, 60, 0.5),
          // Center bubble
          Center(
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.accent,
                boxShadow: [
                  BoxShadow(
                    color: c.accent.withValues(alpha: 0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 16,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                '🧑',
                style: context.tt.headlineMedium!.copyWith(height: 1),
              ),
            ),
          ),
          // Labels
          Positioned(
            top: 180 * 0.20,
            right: 180 * 0.04,
            child: _label(context, c, habitsLabel),
          ),
          Positioned(
            bottom: 180 * 0.25,
            right: 0,
            child: _label(context, c, actionsLabel),
          ),
          Positioned(
            bottom: 180 * 0.10,
            left: 180 * 0.04,
            child: _label(context, c, identityLabel),
          ),
        ],
      ),
    );
  }

  Widget _ring(Color color, double size, double opacity) {
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withValues(alpha: opacity),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _label(BuildContext context, HFColors c, String text) {
    return Text(
      text,
      style: context.tt.bodyMedium!.copyWith(color: c.textTertiary, height: 1.2, letterSpacing: 0.03 * 10, fontWeight: FontWeight.w600, fontSize: 10.0),
    );
  }
}

// ─────────────────────────── Slide 3: Choose path ───────────────────────────

class _Slide3 extends StatelessWidget {
  const _Slide3({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.onboardingS3Title,
                  style: context.tt.headlineLarge!.copyWith(color: c.textPrimary, height: 1.2, letterSpacing: -0.02 * 26),
                ),
                const SizedBox(height: 8),
                Text(
                  l.onboardingS3Sub,
                  style: context.tt.bodyMedium!.copyWith(color: c.textSecondary, height: 1.6),
                ),
                const SizedBox(height: 20),
                _PathCard(
                  emoji: '✨',
                  title: l.onboardingS3Templates,
                  // TODO(l10n): add key onboardingS3TemplatesSub
                  subtitle: 'Рекомендовано',
                  highlighted: true,
                  badgeText: l.onboardingS3BadgeRecommended,
                  onTap: onNext,
                ),
                const SizedBox(height: 12),
                _PathCard(
                  emoji: '✏️',
                  title: l.onboardingS3Custom,
                  subtitle: l.onboardingS3CustomSub,
                  highlighted: false,
                  onTap: onNext,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PathCard extends StatelessWidget {
  const _PathCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.highlighted,
    required this.onTap,
    this.badgeText,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final bool highlighted;
  final String? badgeText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final borderColor = highlighted ? c.accent : c.border;
    final bg = highlighted
        ? c.accent.withValues(alpha: 0.04)
        : c.card;
    final iconBg = highlighted
        ? c.accent.withValues(alpha: 0.12)
        : c.bgTertiary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: borderColor, width: 1.5),
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(emoji, style: context.tt.headlineMedium!.copyWith(height: 1)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: context.tt.bodyLarge!.copyWith(color: c.textPrimary, height: 1.2, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: context.tt.bodySmall!.copyWith(color: c.textSecondary, height: 1.2),
                    ),
                  ],
                ),
              ),
              if (badgeText != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: c.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badgeText!,
                    style: context.tt.labelSmall!.copyWith(color: c.accent, height: 1.2),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── Slide 4: Templates grid ───────────────────────────

class _Slide4 extends StatelessWidget {
  const _Slide4({
    required this.lang,
    required this.selected,
    required this.onToggle,
    required this.onNext,
  });

  final String lang;
  final Set<int> selected;
  final ValueChanged<int> onToggle;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final templates = _templates;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.onboardingS4Title,
            style: context.tt.headlineMedium!.copyWith(color: c.textPrimary, height: 1.2, letterSpacing: -0.02 * 24, fontSize: 24.0),
          ),
          const SizedBox(height: 4),
          Text(
            '${l.onboardingS4Max} · ${l.onboardingS4Selected(selected.length)}/3',
            style: context.tt.bodySmall!.copyWith(color: c.textTertiary, height: 1.2, fontSize: 12.0),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.only(bottom: 4),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.05,
              ),
              itemCount: templates.length,
              itemBuilder: (_, i) {
                final tpl = templates[i];
                return _TemplateCard(
                  emoji: tpl.emoji,
                  name: lang == 'en' ? tpl.nameEn : tpl.nameRu,
                  sub: lang == 'en' ? tpl.subEn : tpl.subRu,
                  selected: selected.contains(i),
                  onTap: () => onToggle(i),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          _PrimaryCta(
            label: l.onboardingS4Btn,
            onPressed: onNext,
            disabled: selected.isEmpty,
          ),
        ],
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.emoji,
    required this.name,
    required this.sub,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String name;
  final String sub;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final borderColor = selected ? c.accent : c.border;
    final bg = selected ? c.accent.withValues(alpha: 0.06) : c.card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: borderColor, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(emoji, style: context.tt.headlineLarge!.copyWith(height: 1)),
                  const SizedBox(height: 6),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: context.tt.titleSmall!.copyWith(color: c.textPrimary, height: 1.2),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    sub,
                    textAlign: TextAlign.center,
                    style: context.tt.labelSmall!.copyWith(color: c.textTertiary, height: 1.3),
                  ),
                ],
              ),
              if (selected)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: c.accent,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── Slide 5: Notifications ───────────────────────────

class _Slide5 extends StatelessWidget {
  const _Slide5({required this.onFinish});

  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  // Bell illustration
                  SizedBox(
                    width: 96,
                    height: 96,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: c.accent.withValues(alpha: 0.1),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '🔔',
                            style: context.tt.displayLarge!.copyWith(height: 1, fontSize: 42.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l.onboardingS5Title,
                      style: context.tt.headlineMedium!.copyWith(color: c.textPrimary, height: 1.2, letterSpacing: -0.02 * 24, fontSize: 24.0),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l.onboardingS5Text,
                      style: context.tt.bodyMedium!.copyWith(color: c.textSecondary, height: 1.65),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const _TelegramPreview(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _PrimaryCta(label: l.onboardingFinish, onPressed: onFinish),
        ],
      ),
    );
  }
}

class _TelegramPreview extends StatelessWidget {
  const _TelegramPreview();

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.bgSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TELEGRAM',
            style: context.tt.labelSmall!.copyWith(color: c.textTertiary, height: 1.2, letterSpacing: 0.04 * 11),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEFF7FF),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '🤖',
                    style: context.tt.bodyLarge!.copyWith(height: 1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.onboardingS5BotName,
                        style: context.tt.labelMedium!.copyWith(color: c.accent, height: 1.2),
                      ),
                      const SizedBox(height: 4),
                      const _TgBubble(),
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

class _TgBubble extends StatelessWidget {
  const _TgBubble();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12),
          bottomLeft: Radius.circular(4),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            offset: Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.onboardingS5TgMsg,
            style: context.tt.bodySmall!.copyWith(color: Color(0xFF222222), height: 1.5),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '09:00 ✓✓',
              style: context.tt.labelSmall!.copyWith(color: const Color(0xFFAAAAAA), height: 1.2),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _TgBtn(label: l.onboardingS5DoneBtn)),
              const SizedBox(width: 6),
              Expanded(child: _TgBtn(label: l.onboardingS5SkipBtn)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TgBtn extends StatelessWidget {
  const _TgBtn({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      alignment: Alignment.center,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: context.tt.labelMedium!.copyWith(color: c.accent, height: 1.2),
      ),
    );
  }
}

// ─────────────────────────── Templates data ───────────────────────────

class _Template {
  const _Template({
    required this.emoji,
    required this.nameRu,
    required this.nameEn,
    required this.subRu,
    required this.subEn,
  });

  final String emoji;
  final String nameRu;
  final String nameEn;
  final String subRu;
  final String subEn;
}

const List<_Template> _templates = [
  _Template(
    emoji: '💧',
    nameRu: 'Пить воду',
    nameEn: 'Drink water',
    subRu: '8 раз в день',
    subEn: '8 times a day',
  ),
  _Template(
    emoji: '🧘',
    nameRu: 'Медитация',
    nameEn: 'Meditation',
    subRu: '10 мин утром',
    subEn: '10 min morning',
  ),
  _Template(
    emoji: '🚶',
    nameRu: 'Прогулка',
    nameEn: 'Walk',
    subRu: '30 мин',
    subEn: '30 min',
  ),
  _Template(
    emoji: '🚭',
    nameRu: 'Без курения',
    nameEn: 'No smoking',
    subRu: 'Анти-привычка',
    subEn: 'Anti-habit',
  ),
  _Template(
    emoji: '📚',
    nameRu: 'Чтение',
    nameEn: 'Reading',
    subRu: '20 мин перед сном',
    subEn: '20 min before bed',
  ),
  _Template(
    emoji: '✍️',
    nameRu: 'Дневник',
    nameEn: 'Journal',
    subRu: 'Каждый вечер',
    subEn: 'Every evening',
  ),
  _Template(
    emoji: '💪',
    nameRu: 'Спорт',
    nameEn: 'Exercise',
    subRu: '3 раза в неделю',
    subEn: '3x per week',
  ),
  _Template(
    emoji: '🌅',
    nameRu: 'Ранний подъём',
    nameEn: 'Early rise',
    subRu: 'до 7:00',
    subEn: 'Before 7:00',
  ),
];
