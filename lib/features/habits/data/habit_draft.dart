import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/habit_type.dart';
import '../domain/schedule_type.dart';
import 'habit_model.dart';

/// Mutable draft accumulated across the 4-step create wizard.
///
/// [toModel] converts the draft into a [HabitModel] ready for
/// [HabitsRepository.create]. All DB-assigned fields (id, createdAt,
/// updatedAt) receive placeholder values; the server overwrites them.
class HabitDraft {
  HabitDraft({
    this.type,
    this.name = '',
    this.category = 'Здоровье',
    this.emoji = '💪',
    this.accentColor,
    this.repeatType = 'Каждый день',
    this.selectedWeekdays = const {},
    this.selectedMonthDays = const {},
    this.timesPerWeek = 3,
    this.everyN = 2,
    this.goalValue = 8,
    this.goalUnit = 'раз',
    this.reminderTimes = const [],
    this.endless = true,
    this.stackingHabit = '',
    this.implementationWhen = '',
    this.implementationWhere = '',
    this.identityStatement = '',
    this.twoMinuteVersion = '',
    this.reward = '',
  });

  final HabitType? type;
  final String name;
  final String category;
  final String emoji;
  final Color? accentColor;

  // Step 3 — schedule
  final String repeatType;
  final Set<String> selectedWeekdays;
  final Set<int> selectedMonthDays;
  final int timesPerWeek;
  final int everyN;
  final int goalValue;
  final String goalUnit;
  final List<String> reminderTimes;
  final bool endless;

  // Step 4 — behavioural techniques
  final String stackingHabit;
  final String implementationWhen;
  final String implementationWhere;
  final String identityStatement;
  final String twoMinuteVersion;
  final String reward;

  HabitDraft copyWith({
    HabitType? type,
    String? name,
    String? category,
    String? emoji,
    Color? accentColor,
    String? repeatType,
    Set<String>? selectedWeekdays,
    Set<int>? selectedMonthDays,
    int? timesPerWeek,
    int? everyN,
    int? goalValue,
    String? goalUnit,
    List<String>? reminderTimes,
    bool? endless,
    String? stackingHabit,
    String? implementationWhen,
    String? implementationWhere,
    String? identityStatement,
    String? twoMinuteVersion,
    String? reward,
  }) {
    return HabitDraft(
      type: type ?? this.type,
      name: name ?? this.name,
      category: category ?? this.category,
      emoji: emoji ?? this.emoji,
      accentColor: accentColor ?? this.accentColor,
      repeatType: repeatType ?? this.repeatType,
      selectedWeekdays: selectedWeekdays ?? this.selectedWeekdays,
      selectedMonthDays: selectedMonthDays ?? this.selectedMonthDays,
      timesPerWeek: timesPerWeek ?? this.timesPerWeek,
      everyN: everyN ?? this.everyN,
      goalValue: goalValue ?? this.goalValue,
      goalUnit: goalUnit ?? this.goalUnit,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      endless: endless ?? this.endless,
      stackingHabit: stackingHabit ?? this.stackingHabit,
      implementationWhen: implementationWhen ?? this.implementationWhen,
      implementationWhere: implementationWhere ?? this.implementationWhere,
      identityStatement: identityStatement ?? this.identityStatement,
      twoMinuteVersion: twoMinuteVersion ?? this.twoMinuteVersion,
      reward: reward ?? this.reward,
    );
  }

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------

  /// Returns true when all required fields for a valid DB insert are present.
  bool get isValid {
    if (type == null) return false;
    final trimmedName = name.trim();
    if (trimmedName.isEmpty || trimmedName.length > 60) return false;
    if (!_scheduleIsValid) return false;
    return true;
  }

  bool get _scheduleIsValid {
    switch (repeatType) {
      case 'По дням недели':
        return selectedWeekdays.isNotEmpty;
      default:
        return true;
    }
  }

  // ---------------------------------------------------------------------------
  // Conversion
  // ---------------------------------------------------------------------------

  /// Converts to a [HabitModel] using [userId].
  ///
  /// The `id`, `createdAt`, `updatedAt` placeholders are overwritten by the
  /// server on insert.
  HabitModel toModel(String userId) {
    final now = DateTime.now();

    // Accent color → hex string
    final colorHex = accentColor != null
        ? '#${accentColor!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}'
        : '#3B82F6';

    // Anti-habit default emoji
    final resolvedEmoji =
        (type == HabitType.anti && emoji.isEmpty) ? '🛡' : emoji;

    return HabitModel(
      // Empty marker — habits_repository.create strips it so DB generates uuid.
      id: '',
      userId: userId,
      name: name.trim(),
      category: category,
      type: type!,
      emoji: resolvedEmoji.isEmpty ? null : resolvedEmoji,
      accentColor: colorHex,
      target: (type == HabitType.countable || type == HabitType.timed)
          ? goalValue.toDouble()
          : null,
      unit: (type == HabitType.countable || type == HabitType.timed)
          ? goalUnit
          : null,
      scheduleType: _toScheduleType(),
      schedule: _buildScheduleConfig(),
      reminderTimes: List<String>.from(reminderTimes),
      startedAt: DateTime(now.year, now.month, now.day),
      endedAt: null,
      stackAfterHabitId: null,
      implementationWhen:
          implementationWhen.trim().isEmpty ? null : implementationWhen.trim(),
      implementationWhere:
          implementationWhere.trim().isEmpty ? null : implementationWhere.trim(),
      identityStatement:
          identityStatement.trim().isEmpty ? null : identityStatement.trim(),
      twoMinuteVersion:
          twoMinuteVersion.trim().isEmpty ? null : twoMinuteVersion.trim(),
      reward: reward.trim().isEmpty ? null : reward.trim(),
      createdAt: now,
      updatedAt: now,
    );
  }

  ScheduleType _toScheduleType() {
    switch (repeatType) {
      case 'По дням недели':
        return ScheduleType.weekdays;
      case 'X раз в неделю':
        return ScheduleType.nPerWeek;
      case 'Каждые N дней':
        return ScheduleType.everyNDays;
      case 'По датам месяца':
        return ScheduleType.monthlyDates;
      default:
        return ScheduleType.daily;
    }
  }

  Map<String, dynamic> _buildScheduleConfig() {
    switch (repeatType) {
      case 'По дням недели':
        // Convert weekday abbreviations to ISO weekday numbers (Пн=1..Вс=7).
        const abbrs = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
        final isoNums = selectedWeekdays
            .map((d) => abbrs.indexOf(d) + 1)
            .where((n) => n > 0)
            .toList()
          ..sort();
        return {'weekdays': isoNums};
      case 'X раз в неделю':
        return {'n': timesPerWeek};
      case 'Каждые N дней':
        return {'every_n': everyN};
      case 'По датам месяца':
        return {'dates': selectedMonthDays.toList()..sort()};
      default:
        return const <String, dynamic>{};
    }
  }
}

// ---------------------------------------------------------------------------
// Riverpod notifier
// ---------------------------------------------------------------------------

class HabitDraftNotifier extends Notifier<HabitDraft> {
  @override
  HabitDraft build() => HabitDraft();

  void reset() => state = HabitDraft();

  void setType(HabitType type) => state = state.copyWith(type: type);

  void setName(String name) => state = state.copyWith(name: name);

  void setCategory(String category) =>
      state = state.copyWith(category: category);

  void setEmoji(String emoji) => state = state.copyWith(emoji: emoji);

  void setAccentColor(Color color) =>
      state = state.copyWith(accentColor: color);

  void setRepeatType(String repeatType) =>
      state = state.copyWith(repeatType: repeatType);

  void toggleWeekday(String day) {
    final updated = Set<String>.from(state.selectedWeekdays);
    if (updated.contains(day)) {
      updated.remove(day);
    } else {
      updated.add(day);
    }
    state = state.copyWith(selectedWeekdays: updated);
  }

  void toggleMonthDay(int day) {
    final updated = Set<int>.from(state.selectedMonthDays);
    if (updated.contains(day)) {
      updated.remove(day);
    } else {
      updated.add(day);
    }
    state = state.copyWith(selectedMonthDays: updated);
  }

  void setTimesPerWeek(int value) =>
      state = state.copyWith(timesPerWeek: value);

  void setEveryN(int value) => state = state.copyWith(everyN: value);

  void setGoalValue(int value) => state = state.copyWith(goalValue: value);

  void setGoalUnit(String unit) => state = state.copyWith(goalUnit: unit);

  void addReminder(String time) {
    final updated = List<String>.from(state.reminderTimes)..add(time);
    state = state.copyWith(reminderTimes: updated);
  }

  void removeReminder(int index) {
    final updated = List<String>.from(state.reminderTimes)..removeAt(index);
    state = state.copyWith(reminderTimes: updated);
  }

  void setEndless(bool value) => state = state.copyWith(endless: value);

  void setStackingHabit(String value) =>
      state = state.copyWith(stackingHabit: value);

  void setImplementationWhen(String value) =>
      state = state.copyWith(implementationWhen: value);

  void setImplementationWhere(String value) =>
      state = state.copyWith(implementationWhere: value);

  void setIdentityStatement(String value) =>
      state = state.copyWith(identityStatement: value);

  void setTwoMinuteVersion(String value) =>
      state = state.copyWith(twoMinuteVersion: value);

  void setReward(String value) => state = state.copyWith(reward: value);
}

final habitDraftProvider =
    NotifierProvider<HabitDraftNotifier, HabitDraft>(HabitDraftNotifier.new);
