import 'package:habit_flow/core/config/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/config/tokens.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../shared/widgets/hf_button.dart';
import '../../../shared/widgets/hf_checkbox.dart';
import '../../../shared/widgets/hf_chip.dart';
import '../../../shared/widgets/hf_input.dart';
import '../../../shared/widgets/hf_slider.dart';
import '../data/habit_draft.dart';
import '../data/habits_providers.dart';
import '../domain/habit_type.dart';

// см. issue #2
const _categories = <String>[
  'Здоровье',
  'Спорт',
  'Учёба',
  'Работа',
  'Отношения',
  'Финансы',
  'Хобби',
  'Ментальное',
  '+ Новая',
];

const _emojiSets = <String, List<String>>{
  'Здоровье': ['🥗', '🥦', '💊', '🩺', '🫀', '🩹', '🧬', '💉', '🫁', '🧠', '🦷', '🏥', '🧪', '🍎', '🥑', '🫖'],
  'Спорт': ['🏃', '💪', '🧘', '🚴', '🏊', '⚽', '🎾', '🏋️', '🤸', '🥊', '🏅', '🎯', '🧗', '🛹', '⛷️', '🏄'],
  'Учёба': ['📚', '✏️', '🎓', '📖', '🔬', '🔭', '💻', '📝', '🗂️', '📐', '📓', '🧮', '📊', '🖊️', '🗃️', '📜'],
  'Работа': ['💼', '📧', '🖥️', '📱', '📅', '⏰', '💡', '📈', '🗓️', '🖨️', '☕', '🧑‍💼', '📞', '🔧', '📌', '🗝️'],
  'Отношения': ['❤️', '👨‍👩‍👧', '🤝', '💌', '🎁', '🥂', '💑', '👨‍👩‍👦', '🫂', '💬', '📸', '🌹', '💍', '🏡', '🫶', '✨'],
  'Финансы': ['💰', '📉', '💳', '🏦', '💵', '📊', '🪙', '💹', '🏧', '💎', '🤑', '📑', '💸', '🔐', '📒', '🎰'],
  'Хобби': ['🎨', '🎸', '📷', '✂️', '🧩', '🎮', '📻', '🎭', '🖌️', '🎼', '🧵', '🪴', '♟️', '🎲', '🪁', '🎻'],
  'Ментальное': ['🧘', '😌', '🌿', '🕯️', '📔', '🫧', '🌊', '☁️', '🌙', '⭐', '🦋', '🌸', '🔮', '🫁', '🌱', '💆'],
};

const _defaultEmoji = ['💪', '🌟', '⚡', '🎯', '🌱', '✨', '🔥', '💡', '🎨', '📚', '🧘', '🌊', '❤️', '🏃', '💎', '🌿'];

const _accentColors = <_AccentColor>[
  _AccentColor('Синий', Color(0xFF3B82F6)),
  _AccentColor('Зелёный', Color(0xFF22C55E)),
  _AccentColor('Амбер', Color(0xFFF59E0B)),
  _AccentColor('Красный', Color(0xFFEF4444)),
  _AccentColor('Фиолет.', Color(0xFFA855F7)),
  _AccentColor('Розовый', Color(0xFFEC4899)),
  _AccentColor('Бирюза', Color(0xFF06B6D4)),
  _AccentColor('Серый', Color(0xFF6B7785)),
];

class _AccentColor {
  const _AccentColor(this.name, this.color);
  final String name;
  final Color color;
}

const _weekdays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

// см. issue #3
const _repeatTypes = [
  'Каждый день',
  'По дням недели',
  'X раз в неделю',
  'Каждые N дней',
  'По датам месяца',
];

/// Placeholder option shown in the stacking dropdown when the user has no
/// habits yet. Renders as the only entry so the field is never empty but
/// still communicates that stacking needs an anchor habit.
const _stackingNoHabitsHint = '— Сначала создай другую привычку —';

class HabitCreateScreen extends ConsumerStatefulWidget {
  const HabitCreateScreen({super.key});

  @override
  ConsumerState<HabitCreateScreen> createState() => _HabitCreateScreenState();
}

class _HabitCreateScreenState extends ConsumerState<HabitCreateScreen> {
  int _step = 1;

  // Local text controllers — kept in widget state because TextEditingController
  // is a UI concern (cursor, focus) not a data concern.
  final _nameCtrl = TextEditingController();
  final _stackingCtrl = TextEditingController();
  final _whenCtrl = TextEditingController();
  final _whereCtrl = TextEditingController();
  final _identityCtrl = TextEditingController();
  final _twoMinCtrl = TextEditingController();
  final _rewardCtrl = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _stackingCtrl.dispose();
    _whenCtrl.dispose();
    _whereCtrl.dispose();
    _identityCtrl.dispose();
    _twoMinCtrl.dispose();
    _rewardCtrl.dispose();
    super.dispose();
  }

  bool _canNext(HabitDraft draft) {
    switch (_step) {
      case 1:
        return draft.type != null;
      case 2:
        return _nameCtrl.text.trim().isNotEmpty &&
            _nameCtrl.text.trim().length <= 60;
      default:
        return true;
    }
  }

  void _back() {
    if (_step > 1) {
      setState(() => _step -= 1);
    } else {
      ref.read(habitDraftProvider.notifier).reset();
      context.pop();
    }
  }

  Future<void> _next(HabitDraft draft) async {
    if (!_canNext(draft)) return;

    // Flush text-field values into the draft before advancing / submitting.
    _flushTextFields();

    if (_step < 4) {
      setState(() => _step += 1);
      return;
    }

    // Step 4 → submit.
    setState(() => _submitting = true);
    try {
      final userId = ref.read(currentUserIdProvider);
      final repo = ref.read(habitsRepositoryProvider);
      final finalDraft = ref.read(habitDraftProvider);
      await repo.create(finalDraft.toModel(userId));
      ref.read(habitDraftProvider.notifier).reset();
      // Logs for today need a refresh so the new habit's empty log slot
      // appears. The habits list itself is updated by realtime stream.
      ref.invalidate(todayLogsProvider);
      if (mounted) {
        context.pop();
      }
    } catch (_) {
      // Error surfacing — keep the user on step 4 so they can retry.
      if (mounted) setState(() => _submitting = false);
      rethrow;
    }
  }

  /// Syncs TextEditingController values → draft notifier so that
  /// [HabitDraft.toModel] has current text when submitting.
  void _flushTextFields() {
    final n = ref.read(habitDraftProvider.notifier);
    n.setName(_nameCtrl.text);
    n.setStackingHabit(_stackingCtrl.text);
    n.setImplementationWhen(_whenCtrl.text);
    n.setImplementationWhere(_whereCtrl.text);
    n.setIdentityStatement(_identityCtrl.text);
    n.setTwoMinuteVersion(_twoMinCtrl.text);
    n.setReward(_rewardCtrl.text);
  }

  void _addReminder() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked == null) return;
    final h = picked.hour.toString().padLeft(2, '0');
    final m = picked.minute.toString().padLeft(2, '0');
    ref.read(habitDraftProvider.notifier).addReminder('$h:$m');
  }

  String _buildRepeatLabel(AppLocalizations l, HabitDraft draft) {
    if (draft.repeatType == 'По дням недели' &&
        draft.selectedWeekdays.isNotEmpty) {
      return _weekdays.where(draft.selectedWeekdays.contains).join(', ');
    }
    if (draft.repeatType == 'X раз в неделю') {
      return l.habitCreateStep3FrequencyValue(draft.timesPerWeek);
    }
    return draft.repeatType;
  }

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final draft = ref.watch(habitDraftProvider);
    final notifier = ref.read(habitDraftProvider.notifier);

    return Scaffold(
      backgroundColor: c.bgSecondary,
      body: SafeArea(
        child: Column(
          children: [
            _WizardHeader(step: _step, onBack: _back),
            Expanded(
              child: SingleChildScrollView(
                key: ValueKey(_step),
                physics: const ClampingScrollPhysics(),
                child: switch (_step) {
                  1 => _Step1(
                      type: draft.type,
                      onChange: notifier.setType,
                    ),
                  2 => _Step2(
                      nameCtrl: _nameCtrl,
                      onNameChanged: (_) => setState(() {}),
                      category: draft.category,
                      onCategory: notifier.setCategory,
                      icon: draft.emoji,
                      onIcon: notifier.setEmoji,
                      accent: draft.accentColor ?? _accentColors.first.color,
                      onAccent: notifier.setAccentColor,
                    ),
                  3 => _Step3(
                      habitType: draft.type,
                      repeatType: draft.repeatType,
                      onRepeatType: notifier.setRepeatType,
                      weekdays: draft.selectedWeekdays,
                      onToggleWeekday: notifier.toggleWeekday,
                      monthDays: draft.selectedMonthDays,
                      onToggleMonthDay: notifier.toggleMonthDay,
                      timesPerWeek: draft.timesPerWeek,
                      onTimesPerWeek: notifier.setTimesPerWeek,
                      everyN: draft.everyN,
                      onEveryN: notifier.setEveryN,
                      goalValue: draft.goalValue,
                      onGoalValue: notifier.setGoalValue,
                      goalUnit: draft.goalUnit,
                      onGoalUnit: notifier.setGoalUnit,
                      reminders: draft.reminderTimes,
                      onAddReminder: _addReminder,
                      onRemoveReminder: notifier.removeReminder,
                      endless: draft.endless,
                      onEndless: notifier.setEndless,
                    ),
                  4 => _Step4(
                      stackingCtrl: _stackingCtrl,
                      whenCtrl: _whenCtrl,
                      whereCtrl: _whereCtrl,
                      identityCtrl: _identityCtrl,
                      twoMinCtrl: _twoMinCtrl,
                      rewardCtrl: _rewardCtrl,
                      habitName: _nameCtrl.text,
                      habitIcon: draft.emoji,
                      habitType: draft.type,
                      accent: draft.accentColor ?? _accentColors.first.color,
                      category: draft.category,
                      repeatLabel: _buildRepeatLabel(l, draft),
                      reminders: draft.reminderTimes,
                      existingHabits: ref
                              .watch(habitsStreamProvider)
                              .valueOrNull
                              ?.map((h) => h.name)
                              .toList() ??
                          const <String>[],
                    ),
                  _ => const SizedBox.shrink(),
                },
              ),
            ),
            _WizardFooter(
              step: _step,
              disabled: !_canNext(draft) || _submitting,
              onNext: () => _next(draft),
            ),
          ],
        ),
      ),
    );
  }
}

class _WizardHeader extends StatelessWidget {
  const _WizardHeader({required this.step, required this.onBack});

  final int step;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    return Container(
      color: c.bgPrimary,
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c.card,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: c.border, width: 1.5),
                    ),
                    child: Icon(
                      step == 1 ? LucideIcons.x : LucideIcons.arrowLeft,
                      size: 18,
                      color: c.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      l.habitCreateStepCounter(step, 4),
                      style: context.tt.labelMedium!.copyWith(color: c.textTertiary, letterSpacing: 0.02 * 12),
                    ),
                  ),
                ),
                const SizedBox(width: 36),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(4, (i) {
                final filled = i + 1 <= step;
                return Expanded(
                  child: Container(
                    height: 3,
                    margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                    decoration: BoxDecoration(
                      color: filled ? c.accent : c.bgTertiary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _WizardFooter extends StatelessWidget {
  const _WizardFooter({
    required this.step,
    required this.disabled,
    required this.onNext,
  });

  final int step;
  final bool disabled;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final label = step < 4 ? l.commonNext : l.habitCreateSubmit;

    return Container(
      decoration: BoxDecoration(
        color: c.bgPrimary,
        border: Border(top: BorderSide(color: c.border, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: GestureDetector(
        onTap: disabled ? null : onNext,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: disabled ? c.bgTertiary : c.accent,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: context.tt.titleMedium!.copyWith(color: disabled ? c.textTertiary : Colors.white, letterSpacing: -0.01 * 15),
          ),
        ),
      ),
    );
  }
}

class _StepHeading extends StatelessWidget {
  const _StepHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.tt.headlineMedium!.copyWith(color: c.textPrimary, height: 1.2, letterSpacing: -0.03 * 24, fontSize: 24.0),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: context.tt.bodyMedium!.copyWith(color: c.textTertiary, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _UpperLabel extends StatelessWidget {
  const _UpperLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Text(
      text.toUpperCase(),
      style: context.tt.labelMedium!.copyWith(color: c.textSecondary, letterSpacing: 0.04 * 12),
    );
  }
}

/* ─── STEP 1: Habit type ─── */
class _Step1 extends StatelessWidget {
  const _Step1({required this.type, required this.onChange});

  final HabitType? type;
  final ValueChanged<HabitType> onChange;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final options = [
      (HabitType.binary, LucideIcons.checkSquare, l.habitTypeBinary, l.habitTypeBinaryDesc, 'Принял витамины'),
      (HabitType.countable, LucideIcons.hash, l.habitTypeCountable, l.habitTypeCountableDesc, '8 стаканов воды'),
      (HabitType.timed, LucideIcons.clock, l.habitTypeTimed, l.habitTypeTimedDesc, 'Медитация 10 минут'),
      (HabitType.anti, LucideIcons.shield, l.habitTypeAnti, l.habitTypeAntiDesc, 'Не пить алкоголь'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeading(
            title: l.habitCreateStep1Title,
            subtitle: l.habitCreateStep1Subtitle,
          ),
          for (final opt in options) ...[
            _TypeCard(
              icon: opt.$2,
              label: opt.$3,
              sub: opt.$4,
              example: opt.$5,
              selected: type == opt.$1,
              isAnti: opt.$1 == HabitType.anti,
              onTap: () => onChange(opt.$1),
            ),
            if (opt != options.last) const SizedBox(height: 10),
          ],
          const SizedBox(height: 4),
          Text(
            'Выбор недоступен — выберите тип ниже.',
            style: context.tt.bodyMedium!.copyWith(color: c.bgPrimary, fontSize: 0.0),
          ),
        ],
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.icon,
    required this.label,
    required this.sub,
    required this.example,
    required this.selected,
    required this.isAnti,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String sub;
  final String example;
  final bool selected;
  final bool isAnti;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final accent = isAnti ? c.anti : c.accent;
    final iconBg = selected
        ? (isAnti ? c.anti.withValues(alpha: 0.15) : c.accent.withValues(alpha: 0.12))
        : (isAnti ? c.anti.withValues(alpha: 0.08) : c.bgSecondary);
    final iconColor = selected || isAnti ? accent : c.textSecondary;

    final border = selected
        ? Border.all(color: accent, width: 2)
        : Border.all(
            color: isAnti ? c.anti.withValues(alpha: 0.25) : c.border,
            width: 1.5,
          );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: isAnti ? c.anti.withValues(alpha: 0.05) : c.card,
          borderRadius: BorderRadius.circular(16),
          border: border,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.08),
                    blurRadius: 0,
                    spreadRadius: 4,
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    size: 22,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: context.tt.titleMedium!.copyWith(color: c.textPrimary, height: 1.2),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sub,
                        style: context.tt.bodySmall!.copyWith(color: isAnti ? c.anti : c.textSecondary, height: 1.3),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Пример: $example',
                        style: context.tt.bodySmall!.copyWith(color: c.textTertiary, height: 1.3, fontSize: 12.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (selected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(LucideIcons.check, size: 12, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/* ─── STEP 2: Name & icon ─── */
class _Step2 extends StatefulWidget {
  const _Step2({
    required this.nameCtrl,
    required this.onNameChanged,
    required this.category,
    required this.onCategory,
    required this.icon,
    required this.onIcon,
    required this.accent,
    required this.onAccent,
  });

  final TextEditingController nameCtrl;
  final ValueChanged<String> onNameChanged;
  final String category;
  final ValueChanged<String> onCategory;
  final String icon;
  final ValueChanged<String> onIcon;
  final Color accent;
  final ValueChanged<Color> onAccent;

  @override
  State<_Step2> createState() => _Step2State();
}

class _Step2State extends State<_Step2> {
  String _iconTab = 'emoji';
  bool _accentOpen = false;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final emojis = _emojiSets[widget.category] ?? _defaultEmoji;
    final selectedColor = _accentColors.firstWhere(
      (a) => a.color.toARGB32() == widget.accent.toARGB32(),
      orElse: () => _accentColors.first,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeading(
            title: l.habitCreateStep2Title,
            subtitle: l.habitCreateStep2Subtitle,
          ),
          // Name
          _UpperLabel(l.commonNameLabel),
          const SizedBox(height: 8),
          HFInput(
            controller: widget.nameCtrl,
            hint: l.habitCreateStep2NameHint,
            onChanged: widget.onNameChanged,
          ),
          const SizedBox(height: 20),

          // Category
          _UpperLabel(l.commonCategoryLabel),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final cat in _categories)
                HFChip(
                  label: cat,
                  selected: widget.category == cat,
                  onTap: () => widget.onCategory(cat),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Icon
          _UpperLabel(l.habitCreateStep2IconLabel),
          const SizedBox(height: 12),
          // Preview circle
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: widget.accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: widget.accent, width: 2.5),
              ),
              alignment: Alignment.center,
              child: Text(
                widget.icon,
                style: context.tt.displayLarge!.copyWith(height: 1, fontSize: 44.0),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tabs
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: c.bgTertiary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _TabButton(
                  label: l.habitCreateStep2EmojiTab,
                  active: _iconTab == 'emoji',
                  onTap: () => setState(() => _iconTab = 'emoji'),
                ),
                _TabButton(
                  label: l.habitCreateStep2PhotoTab,
                  active: _iconTab == 'photo',
                  onTap: () => setState(() => _iconTab = 'photo'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          if (_iconTab == 'emoji')
            GridView.count(
              crossAxisCount: 8,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (final em in emojis)
                  GestureDetector(
                    onTap: () => widget.onIcon(em),
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.icon == em
                            ? c.accent.withValues(alpha: 0.12)
                            : c.bgSecondary,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: widget.icon == em ? c.accent : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(em, style: context.tt.headlineMedium!.copyWith(height: 1)),
                    ),
                  ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
              decoration: BoxDecoration(
                color: c.bgSecondary,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: c.border, width: 2, style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  Icon(LucideIcons.upload, size: 24, color: c.textTertiary),
                  const SizedBox(height: 10),
                  Text(
                    l.habitCreateStep2PhotoUpload,
                    style: context.tt.bodyMedium!.copyWith(color: c.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.habitCreateStep2PhotoHint,
                    style: context.tt.bodySmall!.copyWith(color: c.textTertiary, fontSize: 12.0),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),

          // Accent
          GestureDetector(
            onTap: () => setState(() => _accentOpen = !_accentOpen),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: widget.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    l.habitCreateStep2AccentColorLabel,
                    style: context.tt.labelLarge!.copyWith(color: c.textPrimary),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    selectedColor.name,
                    style: context.tt.bodySmall!.copyWith(color: c.textTertiary, fontSize: 12.0),
                  ),
                  const Spacer(),
                  Icon(
                    _accentOpen ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                    size: 16,
                    color: c.textTertiary,
                  ),
                ],
              ),
            ),
          ),
          if (_accentOpen)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final ac in _accentColors)
                    GestureDetector(
                      onTap: () => widget.onAccent(ac.color),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: ac.color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.accent.toARGB32() == ac.color.toARGB32()
                                ? c.bgPrimary
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: widget.accent.toARGB32() == ac.color.toARGB32()
                              ? [BoxShadow(color: ac.color, blurRadius: 0, spreadRadius: 2.5)]
                              : null,
                        ),
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

class _TabButton extends StatelessWidget {
  const _TabButton({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? c.card : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: active ? HFTokens.cardShadow(c.shadow) : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: context.tt.titleSmall!.copyWith(color: active ? c.textPrimary : c.textTertiary),
          ),
        ),
      ),
    );
  }
}

/* ─── STEP 3: Schedule ─── */
class _Step3 extends StatefulWidget {
  const _Step3({
    required this.habitType,
    required this.repeatType,
    required this.onRepeatType,
    required this.weekdays,
    required this.onToggleWeekday,
    required this.monthDays,
    required this.onToggleMonthDay,
    required this.timesPerWeek,
    required this.onTimesPerWeek,
    required this.everyN,
    required this.onEveryN,
    required this.goalValue,
    required this.onGoalValue,
    required this.goalUnit,
    required this.onGoalUnit,
    required this.reminders,
    required this.onAddReminder,
    required this.onRemoveReminder,
    required this.endless,
    required this.onEndless,
  });

  final HabitType? habitType;
  final String repeatType;
  final ValueChanged<String> onRepeatType;
  final Set<String> weekdays;
  final ValueChanged<String> onToggleWeekday;
  final Set<int> monthDays;
  final ValueChanged<int> onToggleMonthDay;
  final int timesPerWeek;
  final ValueChanged<int> onTimesPerWeek;
  final int everyN;
  final ValueChanged<int> onEveryN;
  final int goalValue;
  final ValueChanged<int> onGoalValue;
  final String goalUnit;
  final ValueChanged<String> onGoalUnit;
  final List<String> reminders;
  final VoidCallback onAddReminder;
  final ValueChanged<int> onRemoveReminder;
  final bool endless;
  final ValueChanged<bool> onEndless;

  @override
  State<_Step3> createState() => _Step3State();
}

class _Step3State extends State<_Step3> {
  bool _periodOpen = false;

  List<String> get _units {
    return switch (widget.habitType) {
      HabitType.countable => ['раз', 'стакан', 'страниц', 'подход', 'км'],
      HabitType.timed => ['мин', 'часов'],
      _ => ['раз'],
    };
  }

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final isCountable =
        widget.habitType == HabitType.countable || widget.habitType == HabitType.timed;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeading(title: l.habitCreateStep3Title, subtitle: l.habitCreateStep3Subtitle),

          _UpperLabel(l.habitCreateStep3RepeatTypeLabel),
          const SizedBox(height: 8),
          _SelectField(
            value: widget.repeatType,
            options: _repeatTypes,
            onChanged: widget.onRepeatType,
          ),
          const SizedBox(height: 20),

          if (widget.repeatType == 'По дням недели') ...[
            Row(
              children: [
                for (var i = 0; i < _weekdays.length; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => widget.onToggleWeekday(_weekdays[i]),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                        decoration: BoxDecoration(
                          color: widget.weekdays.contains(_weekdays[i])
                              ? c.accent
                              : c.bgSecondary,
                          borderRadius: BorderRadius.circular(10),
                          border: widget.weekdays.contains(_weekdays[i])
                              ? null
                              : Border.all(color: c.border, width: 1.5),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _weekdays[i],
                          style: context.tt.labelMedium!.copyWith(
                            color: widget.weekdays.contains(_weekdays[i])
                                ? Colors.white
                                : c.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
          ],

          if (widget.repeatType == 'X раз в неделю') ...[
            Container(
              decoration: BoxDecoration(
                color: c.bgSecondary,
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        l.habitCreateStep3FrequencyLabel,
                        style: context.tt.bodyMedium!.copyWith(color: c.textSecondary),
                      ),
                      const Spacer(),
                      Text(
                        l.habitCreateStep3FrequencyValue(widget.timesPerWeek),
                        style: context.tt.headlineSmall!.copyWith(color: c.accent),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  HFSlider(
                    value: widget.timesPerWeek.toDouble(),
                    min: 1,
                    max: 7,
                    divisions: 6,
                    onChanged: (v) => widget.onTimesPerWeek(v.round()),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('1', style: context.tt.labelSmall!.copyWith(color: c.textTertiary)),
                      Text('7', style: context.tt.labelSmall!.copyWith(color: c.textTertiary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          if (widget.repeatType == 'Каждые N дней') ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: c.bgSecondary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    // см. issue #4
                    child: Text(
                      'Каждые',
                      style: context.tt.bodyMedium!.copyWith(color: c.textSecondary),
                    ),
                  ),
                  _StepperButton(
                    icon: '−',
                    onTap: () => widget.onEveryN((widget.everyN - 1).clamp(1, 365)),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 24,
                    child: Text(
                      '${widget.everyN}',
                      textAlign: TextAlign.center,
                      style: context.tt.headlineSmall!.copyWith(color: c.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StepperButton(
                    icon: '+',
                    onTap: () => widget.onEveryN(widget.everyN + 1),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'дней',
                    style: context.tt.bodyMedium!.copyWith(color: c.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          if (widget.repeatType == 'По датам месяца') ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: c.bgSecondary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.habitCreateStep3SelectDays,
                    style: context.tt.labelMedium!.copyWith(color: c.textTertiary, letterSpacing: 0.05 * 12),
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 7,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      for (var d = 1; d <= 31; d++)
                        GestureDetector(
                          onTap: () => widget.onToggleMonthDay(d),
                          child: Container(
                            decoration: BoxDecoration(
                              color: widget.monthDays.contains(d) ? c.accent : c.card,
                              borderRadius: BorderRadius.circular(8),
                              border: widget.monthDays.contains(d)
                                  ? null
                                  : Border.all(color: c.border, width: 1),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$d',
                              style: context.tt.labelMedium!.copyWith(
                                color: widget.monthDays.contains(d)
                                    ? Colors.white
                                    : c.textSecondary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          if (isCountable) ...[
            _UpperLabel(l.habitCreateStep3GoalLabel),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: c.bgSecondary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _StepperButton(
                    icon: '−',
                    onTap: () => widget.onGoalValue((widget.goalValue - 1).clamp(1, 9999)),
                    big: true,
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '${widget.goalValue}',
                      textAlign: TextAlign.center,
                      style: context.tt.headlineMedium!.copyWith(color: c.textPrimary, fontSize: 24.0),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _StepperButton(
                    icon: '+',
                    onTap: () => widget.onGoalValue(widget.goalValue + 1),
                    big: true,
                  ),
                  const Spacer(),
                  _SelectField(
                    value: _units.contains(widget.goalUnit) ? widget.goalUnit : _units.first,
                    options: _units,
                    onChanged: widget.onGoalUnit,
                    compact: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Reminders
          _UpperLabel(l.habitCreateStep3RemindersLabel),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: c.bgSecondary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                if (widget.reminders.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: c.border, width: 1)),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (var i = 0; i < widget.reminders.length; i++)
                          _ReminderChip(
                            time: widget.reminders[i],
                            onRemove: () => widget.onRemoveReminder(i),
                          ),
                      ],
                    ),
                  ),
                GestureDetector(
                  onTap: widget.onAddReminder,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: c.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Icon(LucideIcons.plus, size: 16, color: c.accent),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          l.habitCreateStep3AddReminder,
                          style: context.tt.labelLarge!.copyWith(color: c.accent),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.habitCreateStep3RemindersHint,
            style: context.tt.bodySmall!.copyWith(color: c.textTertiary, height: 1.5, fontSize: 12.0),
          ),
          const SizedBox(height: 20),

          // Period accordion
          Container(
            decoration: BoxDecoration(
              color: c.bgSecondary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _periodOpen = !_periodOpen),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Icon(LucideIcons.calendar, size: 16, color: c.textTertiary),
                        const SizedBox(width: 10),
                        Text(
                          l.habitCreateStep3PeriodLabel,
                          style: context.tt.labelLarge!.copyWith(color: c.textPrimary),
                        ),
                        const Spacer(),
                        Icon(
                          _periodOpen ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                          size: 16,
                          color: c.textTertiary,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_periodOpen)
                  Container(
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: c.border, width: 1)),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.habitCreateStep3StartDateLabel,
                          style: context.tt.labelMedium!.copyWith(color: c.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: c.card,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: c.border, width: 1.5),
                          ),
                          child: Text(
                            '07.05.2026',
                            style: context.tt.bodyMedium!.copyWith(color: c.textPrimary),
                          ),
                        ),
                        const SizedBox(height: 12),
                        HFCheckbox(
                          value: widget.endless,
                          onChanged: widget.onEndless,
                          label: l.habitCreateStep3Endless,
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

class _StackingPicker extends StatelessWidget {
  const _StackingPicker({
    required this.controller,
    required this.existingHabits,
  });

  final TextEditingController controller;
  final List<String> existingHabits;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    if (existingHabits.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: c.bgSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.border, width: 1.5),
        ),
        child: Text(
          _stackingNoHabitsHint,
          style: context.tt.bodySmall!.copyWith(color: c.textTertiary, fontStyle: FontStyle.italic),
        ),
      );
    }
    final value = existingHabits.contains(controller.text)
        ? controller.text
        : existingHabits.first;
    return _SelectField(
      value: value,
      options: existingHabits,
      onChanged: (v) => controller.text = v,
    );
  }
}

class _SelectField extends StatelessWidget {
  const _SelectField({
    required this.value,
    required this.options,
    required this.onChanged,
    this.compact = false,
  });

  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 14,
        vertical: compact ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(compact ? 10 : 12),
        border: Border.all(color: c.border, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          icon: Icon(LucideIcons.chevronDown, size: 14, color: c.textTertiary),
          style: context.tt.bodyMedium!.copyWith(color: c.textPrimary),
          dropdownColor: c.card,
          items: [
            for (final o in options)
              DropdownMenuItem(value: o, child: Text(o)),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap, this.big = false});

  final String icon;
  final VoidCallback onTap;
  final bool big;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final size = big ? 36.0 : 34.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: c.border, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          icon,
          style: context.tt.bodyMedium!.copyWith(color: c.textPrimary, height: 1),
        ),
      ),
    );
  }
}

class _ReminderChip extends StatelessWidget {
  const _ReminderChip({required this.time, required this.onRemove});

  final String time;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 10, 6),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.border, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.clock, size: 13, color: c.accent),
          const SizedBox(width: 6),
          Text(
            time,
            style: context.tt.titleSmall!.copyWith(color: c.textPrimary),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Icon(LucideIcons.x, size: 13, color: c.textTertiary),
          ),
        ],
      ),
    );
  }
}

/* ─── STEP 4: Behavioral techniques ─── */
class _Step4 extends StatelessWidget {
  const _Step4({
    required this.stackingCtrl,
    required this.whenCtrl,
    required this.whereCtrl,
    required this.identityCtrl,
    required this.twoMinCtrl,
    required this.rewardCtrl,
    required this.habitName,
    required this.habitIcon,
    required this.habitType,
    required this.accent,
    required this.category,
    required this.repeatLabel,
    required this.reminders,
    required this.existingHabits,
  });

  final TextEditingController stackingCtrl;
  final TextEditingController whenCtrl;
  final TextEditingController whereCtrl;
  final TextEditingController identityCtrl;
  final TextEditingController twoMinCtrl;
  final TextEditingController rewardCtrl;
  final String habitName;
  final String habitIcon;
  final HabitType? habitType;
  final Color accent;
  final String category;
  final String repeatLabel;
  final List<String> reminders;
  final List<String> existingHabits;

  String _typeLabel(AppLocalizations l) {
    return switch (habitType) {
      HabitType.binary => l.habitTypeBinary,
      HabitType.countable => l.habitTypeCountable,
      HabitType.timed => l.habitTypeTimed,
      HabitType.anti => l.habitTypeAnti,
      _ => 'Тип',
    };
  }

  String _todayActionLabel(AppLocalizations l) {
    return switch (habitType) {
      HabitType.binary => l.habitCreateStep4ActionBinary,
      HabitType.anti => l.habitCreateStep4ActionAnti,
      _ => l.habitCreateStep4ActionOther,
    };
  }

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.habitCreateStep4Title,
                  style: context.tt.headlineMedium!.copyWith(color: c.textPrimary, height: 1.2, letterSpacing: -0.03 * 24, fontSize: 24.0),
                ),
                const SizedBox(height: 6),
                Text(
                  l.habitCreateStep4Subtitle,
                  style: context.tt.bodySmall!.copyWith(color: c.textTertiary, height: 1.6),
                ),
              ],
            ),
          ),

          _AccordionSection(
            emoji: '🧱',
            title: l.habitCreateStep4StackingTitle,
            subtitle: l.habitCreateStep4StackingSubtitle,
            child: _StackingPicker(
              controller: stackingCtrl,
              existingHabits: existingHabits,
            ),
          ),
          const SizedBox(height: 10),

          _AccordionSection(
            emoji: '📍',
            title: l.habitCreateStep4IntentionTitle,
            subtitle: l.habitCreateStep4IntentionSubtitle,
            child: Column(
              children: [
                HFInput(
                  controller: whenCtrl,
                  hint: l.habitCreateStep4IntentionWhenHint,
                ),
                const SizedBox(height: 10),
                HFInput(
                  controller: whereCtrl,
                  hint: l.habitCreateStep4IntentionWhereHint,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          _AccordionSection(
            emoji: '🎭',
            title: l.habitCreateStep4IdentityTitle,
            subtitle: l.habitCreateStep4IdentitySubtitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HFInput(
                  controller: identityCtrl,
                  hint: l.habitCreateStep4IdentityHint,
                  minLines: 3,
                  maxLines: 5,
                ),
                const SizedBox(height: 8),
                Text(
                  l.habitCreateStep4IdentityNote,
                  style: context.tt.bodySmall!.copyWith(color: c.textTertiary, height: 1.5, fontSize: 12.0),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          _AccordionSection(
            emoji: '⚡',
            title: l.habitCreateStep4TwoMinTitle,
            subtitle: l.habitCreateStep4TwoMinSubtitle,
            child: HFInput(
              controller: twoMinCtrl,
              hint: l.habitCreateStep4TwoMinHint,
            ),
          ),
          const SizedBox(height: 10),

          _AccordionSection(
            emoji: '🍰',
            title: l.habitCreateStep4RewardTitle,
            subtitle: l.habitCreateStep4RewardSubtitle,
            child: HFInput(
              controller: rewardCtrl,
              hint: l.habitCreateStep4RewardHint,
            ),
          ),
          const SizedBox(height: 28),

          // Preview
          Text(
            l.habitCreateStep4PreviewLabel,
            style: context.tt.labelMedium!.copyWith(color: c.textTertiary, letterSpacing: 0.06 * 12),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: c.bgSecondary,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: c.border, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: c.shadow,
                  offset: const Offset(0, 2),
                  blurRadius: 12,
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: accent, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        habitIcon.isEmpty ? '🌟' : habitIcon,
                        style: context.tt.headlineLarge!.copyWith(height: 1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habitName.isEmpty ? l.habitCreateStep4PreviewName : habitName,
                            style: context.tt.bodyLarge!.copyWith(color: c.textPrimary, letterSpacing: -0.02 * 16, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$category · ${_typeLabel(l)}',
                            style: context.tt.bodySmall!.copyWith(color: c.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          l.habitCreateStep4PreviewStreak,
                          style: context.tt.labelSmall!.copyWith(color: c.textTertiary, letterSpacing: 0.04 * 11),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '0',
                          style: context.tt.headlineMedium!.copyWith(color: accent, height: 1),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(height: 1, color: c.border),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetaPill(
                      icon: LucideIcons.refreshCw,
                      label: repeatLabel,
                    ),
                    if (reminders.isNotEmpty)
                      _MetaPill(
                        icon: LucideIcons.bell,
                        label: reminders.length > 1
                            ? '${reminders.first} +${reminders.length - 1}'
                            : reminders.first,
                      ),
                    _NewBadge(),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: c.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: c.border, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.habitCreateStep4PreviewToday,
                              style: context.tt.labelSmall!.copyWith(color: c.textTertiary, letterSpacing: 0.04 * 11),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _todayActionLabel(l),
                              style: context.tt.bodySmall!.copyWith(color: c.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: accent, width: 1.5),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          habitType == HabitType.anti
                              ? LucideIcons.shieldCheck
                              : LucideIcons.check,
                          size: 20,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          HFButton(
            label: l.habitCreateStep4Reset,
            variant: HFButtonVariant.ghost,
            size: HFButtonSize.sm,
            fullWidth: true,
            onPressed: () {
              stackingCtrl.clear();
              whenCtrl.clear();
              whereCtrl.clear();
              identityCtrl.clear();
              twoMinCtrl.clear();
              rewardCtrl.clear();
            },
          ),
        ],
      ),
    );
  }
}

class _AccordionSection extends StatefulWidget {
  const _AccordionSection({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  State<_AccordionSection> createState() => _AccordionSectionState();
}

class _AccordionSectionState extends State<_AccordionSection> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _open = !_open),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Text(widget.emoji, style: context.tt.headlineMedium!.copyWith(height: 1)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: context.tt.labelLarge!.copyWith(color: c.textPrimary),
                        ),
                        if (!_open) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle,
                            style: context.tt.bodySmall!.copyWith(color: c.textTertiary, fontSize: 12.0),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    _open ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                    size: 18,
                    color: c.textTertiary,
                  ),
                ],
              ),
            ),
          ),
          if (_open)
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: c.border, width: 1)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.subtitle,
                    style: context.tt.bodySmall!.copyWith(color: c.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  widget.child,
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: c.textTertiary),
          const SizedBox(width: 5),
          Text(
            label,
            style: context.tt.bodySmall!.copyWith(color: c.textSecondary, fontSize: 12.0),
          ),
        ],
      ),
    );
  }
}

class _NewBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.accent.withValues(alpha: 0.2), width: 1),
      ),
      child: Text(
        l.commonNewBadge,
        style: context.tt.labelMedium!.copyWith(color: c.accent),
      ),
    );
  }
}
