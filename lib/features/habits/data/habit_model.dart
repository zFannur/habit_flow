import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/habit_status.dart';
import '../domain/habit_type.dart';
import '../domain/schedule_type.dart';

part 'habit_model.freezed.dart';
part 'habit_model.g.dart';

/// Mirrors a row in `habits` (SPEC §5).
///
/// Behaviour-science fields (`stackAfterHabitId`, `implementationWhen`,
/// `implementationWhere`, `identityStatement`, `twoMinuteVersion`, `reward`)
/// are optional and surface in the create-wizard step 4 (SPEC §8).
@freezed
class HabitModel with _$HabitModel {
  const HabitModel._();

  const factory HabitModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String name,

    /// Free-text category label as stored in the DB column `category`. The
    /// id of a structured category lives separately in [categoryId] (joined
    /// from `habit_categories` when present).
    String? category,
    @JsonKey(name: 'category_id') String? categoryId,
    @JsonKey(
      name: 'habit_type',
      fromJson: _typeFromJson,
      toJson: _typeToJson,
    )
    required HabitType type,
    @JsonKey(name: 'icon_emoji') String? emoji,
    @JsonKey(name: 'icon_telegram_file_id') String? iconTelegramFileId,
    @JsonKey(name: 'color') String? accentColor,

    // Target (countable / timed)
    @JsonKey(name: 'target_value') double? target,
    @JsonKey(name: 'target_unit') String? unit,

    // Schedule
    @JsonKey(
      name: 'schedule_type',
      fromJson: _scheduleTypeFromJson,
      toJson: _scheduleTypeToJson,
    )
    required ScheduleType scheduleType,
    @JsonKey(name: 'schedule_config')
    @Default(<String, dynamic>{})
    Map<String, dynamic> schedule,
    @JsonKey(
      name: 'reminder_times',
      fromJson: _reminderTimesFromJson,
      toJson: _reminderTimesToJson,
    )
    @Default(<String>[])
    List<String> reminderTimes,
    @JsonKey(name: 'start_date', fromJson: _dateFromJson, toJson: _dateToJson)
    required DateTime startedAt,
    @JsonKey(
      name: 'end_date',
      fromJson: _dateFromJsonNullable,
      toJson: _dateToJsonNullable,
    )
    DateTime? endedAt,

    // Behaviour science
    @JsonKey(name: 'stack_after_habit_id') String? stackAfterHabitId,
    @JsonKey(name: 'implementation_when') String? implementationWhen,
    @JsonKey(name: 'implementation_where') String? implementationWhere,
    @JsonKey(name: 'identity_statement') String? identityStatement,
    @JsonKey(name: 'two_minute_version') String? twoMinuteVersion,
    String? reward,

    // State
    @JsonKey(name: 'is_archived') @Default(false) bool isArchived,
    @Default(0) int position,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _HabitModel;

  factory HabitModel.fromJson(Map<String, dynamic> json) =>
      _$HabitModelFromJson(json);

  // -------------------------------------------------------------------------
  // Computed getters
  // -------------------------------------------------------------------------

  bool get isBinary => type == HabitType.binary;
  bool get isCountable => type == HabitType.countable;
  bool get isTimed => type == HabitType.timed;
  bool get isAnti => type == HabitType.anti;

  /// DB stores only `is_archived` + `end_date`. We project that into a
  /// 3-state status for UI ergonomics.
  HabitStatus get status {
    if (isArchived) return HabitStatus.archived;
    if (endedAt != null && !endedAt!.isAfter(DateTime.now())) {
      return HabitStatus.paused;
    }
    return HabitStatus.active;
  }

  /// `true` when [day] falls within the habit's lifetime AND the cadence
  /// (`scheduleType` + `schedule` config) selects this calendar day.
  ///
  /// Only the date part of [day] is considered.
  bool isToday(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    final start = DateTime(startedAt.year, startedAt.month, startedAt.day);
    if (d.isBefore(start)) return false;
    if (endedAt != null) {
      final end = DateTime(endedAt!.year, endedAt!.month, endedAt!.day);
      if (d.isAfter(end)) return false;
    }
    if (isArchived) return false;

    switch (scheduleType) {
      case ScheduleType.daily:
        return true;

      case ScheduleType.weekdays:
        // ISO weekday: Mon=1..Sun=7. schedule_config: {"weekdays":[1,3,5]}.
        final weekdays = (schedule['weekdays'] as List?)?.cast<num>() ?? const [];
        return weekdays.map((e) => e.toInt()).contains(d.weekday);

      case ScheduleType.everyNDays:
        final n = (schedule['every_n'] as num?)?.toInt() ?? 1;
        if (n <= 0) return false;
        final diff = d.difference(start).inDays;
        return diff % n == 0;

      case ScheduleType.monthlyDates:
        final dates = (schedule['dates'] as List?)?.cast<num>() ?? const [];
        return dates.map((e) => e.toInt()).contains(d.day);

      case ScheduleType.nPerWeek:
        // "Любые N дней в неделю" — конкретные дни решаются в UI/логе, не в
        // расписании. Возвращаем true, чтобы привычка отображалась каждый
        // день, пока не выполнена N раз за неделю.
        return true;
    }
  }
}

// =============================================================================
// JSON converters
// =============================================================================

HabitType _typeFromJson(String v) => HabitType.fromString(v);
String _typeToJson(HabitType t) => t.wireName;

ScheduleType _scheduleTypeFromJson(String v) => ScheduleType.fromString(v);
String _scheduleTypeToJson(ScheduleType s) => s.wireName;

DateTime _dateFromJson(String iso) => DateTime.parse(iso);

String _dateToJson(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

DateTime? _dateFromJsonNullable(String? iso) =>
    iso == null ? null : DateTime.parse(iso);

String? _dateToJsonNullable(DateTime? d) => d == null ? null : _dateToJson(d);

// Postgres TIME[] arrives as JSON list of strings like `"21:30:00"`.
List<String> _reminderTimesFromJson(dynamic raw) {
  if (raw == null) return const [];
  if (raw is List) return raw.map((e) => e.toString()).toList();
  return const [];
}

List<String> _reminderTimesToJson(List<String> times) => times;
