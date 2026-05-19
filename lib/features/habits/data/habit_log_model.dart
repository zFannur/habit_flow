import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/habit_log_status.dart';

part 'habit_log_model.freezed.dart';
part 'habit_log_model.g.dart';

/// Mirrors a row in `habit_logs` (SPEC §5).
///
/// `(habit_id, log_date)` is unique, so a single log represents the state of
/// one habit on one calendar day.
@freezed
class HabitLogModel with _$HabitLogModel {
  const HabitLogModel._();

  const factory HabitLogModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'habit_id') required String habitId,
    @JsonKey(name: 'log_date', fromJson: _dateFromJson, toJson: _dateToJson)
    required DateTime date,
    @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
    required HabitLogStatus status,

    /// For countable / timed habits: how much was logged on [date].
    /// For binary / anti habits: typically `null`.
    double? value,
    String? comment,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _HabitLogModel;

  factory HabitLogModel.fromJson(Map<String, dynamic> json) =>
      _$HabitLogModelFromJson(json);

  bool get isDone => status == HabitLogStatus.done;
  bool get isPartial => status == HabitLogStatus.partial;
  bool get isMissed => status == HabitLogStatus.missed;
  bool get isSkipped => status == HabitLogStatus.skipped;

  /// Whether this log refers to the same calendar day as [other].
  /// Compares only Y/M/D — time-of-day is irrelevant for habit logs.
  bool isOnDay(DateTime other) =>
      date.year == other.year &&
      date.month == other.month &&
      date.day == other.day;
}

// `log_date` is a Postgres DATE — Supabase serialises it as `YYYY-MM-DD`.
// We round-trip through that exact wire format so toJson(fromJson(x)) == x.
DateTime _dateFromJson(String iso) => DateTime.parse(iso);

String _dateToJson(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

HabitLogStatus _statusFromJson(String v) => HabitLogStatus.fromString(v);
String _statusToJson(HabitLogStatus s) => s.wireName;
