import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:uuid/uuid.dart';

import '../../../core/config/tokens.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../shared/widgets/hf_slider.dart';
import '../data/journal_entry_model.dart';
import '../data/journal_providers.dart';
import '../data/journal_template_provider.dart';

// ---------------------------------------------------------------------------
// Default reflection questions (fallback when users.reflection_template is
// not yet implemented — see task 8-04 for the full template feature).
// ---------------------------------------------------------------------------
List<_Question> _defaultQuestions(AppLocalizations l) => [
      _Question('q1', l.reflectionTemplateQ1),
      _Question('q2', l.reflectionTemplateQ2),
      _Question('q3', l.reflectionTemplateQ3),
      _Question('q4', l.reflectionTemplateQ4),
    ];

/// Returns the active reflection questions: user-customised list from
/// `journalTemplateProvider` if set, otherwise the ARB defaults.
List<_Question> _activeQuestions(WidgetRef ref, AppLocalizations l) {
  final saved = ref.watch(journalTemplateProvider);
  if (saved == null || saved.isEmpty) return _defaultQuestions(l);
  return [
    for (var i = 0; i < saved.length; i++) _Question('q${i + 1}', saved[i]),
  ];
}

class JournalEditScreen extends ConsumerStatefulWidget {
  const JournalEditScreen({super.key, this.entryId});

  /// When non-null, the screen loads and edits an existing entry.
  /// When null, a new entry for today is created on save.
  final String? entryId;

  @override
  ConsumerState<JournalEditScreen> createState() => _JournalEditScreenState();
}

class _JournalEditScreenState extends ConsumerState<JournalEditScreen> {
  int _mood = 7;
  int _energy = 6;
  final TextEditingController _textCtrl = TextEditingController();
  final FocusNode _textFocus = FocusNode();
  bool _showQuestions = false;
  final Map<String, TextEditingController> _answers = {
    'q1': TextEditingController(),
    'q2': TextEditingController(),
    'q3': TextEditingController(),
    'q4': TextEditingController(),
  };

  // Populated from the loaded entry's date, or today for new entries.
  DateTime _entryDate = DateTime.now();

  // Loaded entry id — may be server-assigned UUID after first save.
  String? _loadedId;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _loadError;

  // Habits are static placeholders — task 8-04 will wire real habit logs.
  static const _habits = <_HabitTag>[
    _HabitTag('🧘', true, 'Медитация'),
    _HabitTag('💧', true, 'Вода'),
    _HabitTag('📖', false, 'Чтение'),
    _HabitTag('🛡', true, 'Без сладкого'),
  ];

  @override
  void initState() {
    super.initState();
    _textCtrl.addListener(() => setState(() {}));
    _textFocus.addListener(() => setState(() {}));
    if (widget.entryId != null) {
      _loadEntry(widget.entryId!);
    } else {
      // /journal/new — if today's entry already exists, redirect into edit
      // mode so the user does not silently overwrite it via the unique
      // (user_id, entry_date) upsert.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final existing = ref.read(journalTodayEntryProvider);
        if (existing != null) {
          context.pushReplacement('/journal/${existing.id}');
        }
      });
    }
  }

  Future<void> _loadEntry(String id) async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      // Await the first stream emission so the cache is populated before
      // we search. The repository has no findById; the route only passes
      // ids from the list screen so the entry is present in watchAll().
      final allEntries =
          await ref.read(journalRepositoryProvider).watchAll().first;
      final entry = allEntries.where((e) => e.id == id).firstOrNull;
      if (entry != null) {
        _applyEntry(entry);
      } else {
        setState(() {
          _loadError = 'Entry not found';
        });
      }
    } catch (e) {
      setState(() => _loadError = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyEntry(JournalEntryModel entry) {
    _loadedId = entry.id;
    _entryDate = entry.date;
    _mood = entry.mood ?? 7;
    _energy = entry.energy ?? 6;
    _textCtrl.text = entry.text;
    final answers = entry.answers ?? {};
    for (final key in _answers.keys) {
      _answers[key]!.text = answers[key] ?? '';
    }
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _textFocus.dispose();
    for (final ctrl in _answers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final repo = ref.read(journalRepositoryProvider);
      final userId = ref.read(currentUserIdProvider);

      final answersMap = <String, String>{};
      for (final e in _answers.entries) {
        final text = e.value.text.trim();
        if (text.isNotEmpty) answersMap[e.key] = text;
      }

      final entry = JournalEntryModel(
        id: _loadedId ?? const Uuid().v4(),
        userId: userId,
        date: _entryDate,
        text: _textCtrl.text.trim(),
        mood: _mood,
        energy: _energy,
        answers: answersMap.isEmpty ? null : answersMap,
        // linkedHabitLogIds is left empty — task 8-04 (don't-break-chain)
        // will populate this from today's habit logs.
        linkedHabitLogIds: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final saved = await repo.upsert(entry);
      _loadedId = saved.id;

      ref.invalidate(journalEntriesProvider);

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _formattedDate(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat('EEE, d MMM', locale).format(_entryDate);
  }

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: c.bgSecondary,
        body: Center(
          child: CircularProgressIndicator(color: c.accent),
        ),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        backgroundColor: c.bgSecondary,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.journalEditLoadError,
                style: TextStyle(color: c.textPrimary, fontSize: 16),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.pop(),
                child: Text(l.commonClose),
              ),
            ],
          ),
        ),
      );
    }

    final questions = _activeQuestions(ref, l);

    return Scaffold(
      backgroundColor: c.bgSecondary,
      body: Column(
        children: [
          _Header(
            dateLabel: widget.entryId == null
                ? l.journalEditHeaderToday
                : _formattedDate(context),
            dateSubLabel: _formattedDate(context),
            isSaving: _isSaving,
            onClose: () => context.pop(),
            onSave: _save,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HabitsBlock(habits: _habits),
                  const SizedBox(height: 12),
                  _ScaleSlider(
                    label: l.journalEditMoodLabel,
                    value: _mood,
                    onChanged: (v) => setState(() => _mood = v),
                    minEmoji: '😢',
                    maxEmoji: '😄',
                  ),
                  const SizedBox(height: 12),
                  _ScaleSlider(
                    label: l.journalEditEnergyLabel,
                    value: _energy,
                    onChanged: (v) => setState(() => _energy = v),
                    minEmoji: '🪫',
                    maxEmoji: '🔋',
                  ),
                  const SizedBox(height: 12),
                  _FreeTextCard(
                    controller: _textCtrl,
                    focusNode: _textFocus,
                  ),
                  const SizedBox(height: 12),
                  _QuestionsToggle(
                    open: _showQuestions,
                    onTap: () =>
                        setState(() => _showQuestions = !_showQuestions),
                  ),
                  if (_showQuestions) ...[
                    const SizedBox(height: 10),
                    for (final q in questions) ...[
                      _QuestionField(
                        question: q.text,
                        controller: _answers[q.id]!,
                      ),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 4),
                    _ChangeTemplateLink(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({
    required this.dateLabel,
    required this.dateSubLabel,
    required this.isSaving,
    required this.onClose,
    required this.onSave,
  });

  final String dateLabel;
  final String dateSubLabel;
  final bool isSaving;
  final VoidCallback onClose;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.bgPrimary,
        border: Border(bottom: BorderSide(color: c.border, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            SizedBox(
              width: 64,
              child: InkWell(
                onTap: onClose,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Icon(LucideIcons.x, size: 18, color: c.accent),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dateLabel,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    dateSubLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: c.textTertiary,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 64,
              child: Align(
                alignment: Alignment.centerRight,
                child: isSaving
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: c.accent,
                        ),
                      )
                    : InkWell(
                        onTap: onSave,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            l.journalEditSave,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: c.accent,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _HabitsBlock
// ---------------------------------------------------------------------------

class _HabitsBlock extends StatelessWidget {
  const _HabitsBlock({required this.habits});

  final List<_HabitTag> habits;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: c.bgTertiary,
        borderRadius: BorderRadius.circular(HFTokens.rLg),
        border: Border.all(color: c.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).journalEditHabitsTitle,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: c.textTertiary,
              letterSpacing: 0.06 * 12,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final h in habits) _HabitPill(tag: h),
            ],
          ),
        ],
      ),
    );
  }
}

class _HabitPill extends StatelessWidget {
  const _HabitPill({required this.tag});

  final _HabitTag tag;

  @override
  Widget build(BuildContext context) {
    final bg = tag.done
        ? const Color(0x1A22C55E)
        : const Color(0x14EF4444);
    final border = tag.done
        ? const Color(0x4022C55E)
        : const Color(0x33EF4444);
    final iconColor = tag.done
        ? const Color(0xFF16A34A)
        : const Color(0xFFDC2626);
    final nameColor = tag.done
        ? const Color(0xFF15803D)
        : const Color(0xFFB91C1C);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(HFTokens.rFull),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(tag.icon, style: const TextStyle(fontSize: 13, height: 1.2)),
          const SizedBox(width: 6),
          Text(
            tag.done ? '✅' : '❌',
            style: TextStyle(
              fontSize: 13,
              color: iconColor,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            tag.name,
            style: TextStyle(
              fontSize: 12,
              color: nameColor,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _ScaleSlider
// ---------------------------------------------------------------------------

class _ScaleSlider extends StatelessWidget {
  const _ScaleSlider({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.minEmoji,
    required this.maxEmoji,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final String minEmoji;
  final String maxEmoji;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final color = _moodColor(value);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(HFTokens.rLg),
        border: Border.all(color: c.border, width: 1),
        boxShadow: HFTokens.cardShadow(c.shadow),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                  height: 1.2,
                ),
              ),
              SizedBox(
                width: 32,
                child: Text(
                  '$value',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: -0.02 * 26,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(minEmoji, style: const TextStyle(fontSize: 20, height: 1)),
              const SizedBox(width: 10),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 6,
                    activeTrackColor: color,
                    inactiveTrackColor: c.bgTertiary,
                    thumbColor: c.card,
                    overlayColor: c.accent.withValues(alpha: 0.15),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 18,
                    ),
                    thumbShape: HFSliderThumbShape(
                      borderColor: c.accent,
                      shadowColor: c.accent.withValues(alpha: 0.25),
                      radius: 12.0,
                      border: 2.5,
                    ),
                    trackShape: const RoundedRectSliderTrackShape(),
                  ),
                  child: Slider(
                    min: 1,
                    max: 10,
                    divisions: 9,
                    value: value.toDouble(),
                    onChanged: (v) => onChanged(v.round()),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(maxEmoji, style: const TextStyle(fontSize: 20, height: 1)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 6, 28, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var n = 1; n <= 10; n++)
                  Text(
                    '$n',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight:
                          n == value ? FontWeight.w700 : FontWeight.w400,
                      color: n == value ? color : c.textTertiary,
                      height: 1.2,
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

// ---------------------------------------------------------------------------
// _FreeTextCard
// ---------------------------------------------------------------------------

class _FreeTextCard extends StatelessWidget {
  const _FreeTextCard({required this.controller, required this.focusNode});

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final hasText = controller.text.isNotEmpty;
    final focused = focusNode.hasFocus;
    final borderColor = (hasText || focused) ? c.accent : c.border;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(HFTokens.rLg),
        border: Border.all(color: c.border, width: 1),
        boxShadow: HFTokens.cardShadow(c.shadow),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.journalEditEntryLabel,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            constraints: const BoxConstraints(minHeight: 120),
            decoration: BoxDecoration(
              color: c.bgSecondary,
              borderRadius: BorderRadius.circular(HFTokens.rMd),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              maxLines: null,
              minLines: 6,
              style: TextStyle(
                fontSize: 14,
                color: c.textPrimary,
                height: 1.6,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: l.journalEditPlaceholder,
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: c.textTertiary,
                  height: 1.6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              l.journalEditCharCount(controller.text.length),
              style: TextStyle(
                fontSize: 11,
                color: c.textTertiary,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _QuestionsToggle
// ---------------------------------------------------------------------------

class _QuestionsToggle extends StatelessWidget {
  const _QuestionsToggle({required this.open, required this.onTap});

  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Material(
      color: c.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: open ? c.accent : c.border,
              width: 1.5,
            ),
            boxShadow: HFTokens.cardShadow(c.shadow),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: open
                      ? c.accent.withValues(alpha: 0.12)
                      : c.bgTertiary,
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: Icon(
                  LucideIcons.helpCircle,
                  size: 16,
                  color: open ? c.accent : c.textTertiary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).journalEditQuestionsShow,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                    height: 1.2,
                  ),
                ),
              ),
              if (open) ...[
                Text(
                  AppLocalizations.of(context).journalEditQuestionsHide,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: c.accent,
                    height: 1.2,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              AnimatedRotation(
                turns: open ? 0.5 : 0,
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  LucideIcons.chevronDown,
                  size: 18,
                  color: c.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _QuestionField
// ---------------------------------------------------------------------------

class _QuestionField extends StatefulWidget {
  const _QuestionField({required this.question, required this.controller});

  final String question;
  final TextEditingController controller;

  @override
  State<_QuestionField> createState() => _QuestionFieldState();
}

class _QuestionFieldState extends State<_QuestionField> {
  bool _open = true;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(HFTokens.rMd),
        border: Border.all(color: c.border, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(HFTokens.rMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () => setState(() => _open = !_open),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.question,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: c.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: _open ? 0 : -0.25,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        LucideIcons.chevronDown,
                        size: 16,
                        color: c.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_open)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 60),
                  decoration: BoxDecoration(
                    color: c.bgSecondary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: c.border, width: 1.5),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  child: TextField(
                    controller: widget.controller,
                    maxLines: null,
                    minLines: 2,
                    style: TextStyle(
                      fontSize: 13,
                      color: c.textPrimary,
                      height: 1.5,
                    ),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: AppLocalizations.of(
                        context,
                      ).journalEditQuestionPlaceholder,
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: c.textTertiary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _ChangeTemplateLink
// ---------------------------------------------------------------------------

class _ChangeTemplateLink extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context).journalEditChangeTemplate,
              style: TextStyle(
                fontSize: 13,
                color: c.textTertiary,
                height: 1.2,
              ),
            ),
            const SizedBox(width: 4),
            Icon(LucideIcons.chevronRight, size: 14, color: c.textTertiary),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Color _moodColor(int value) {
  if (value <= 3) return const Color(0xFFEF4444);
  if (value <= 6) return const Color(0xFF9AA0AB);
  return const Color(0xFF22C55E);
}

class _HabitTag {
  const _HabitTag(this.icon, this.done, this.name);
  final String icon;
  final bool done;
  final String name;
}

class _Question {
  const _Question(this.id, this.text);
  final String id;
  final String text;
}
