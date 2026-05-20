// Freezed v2 emits `invalid_annotation_target` for @JsonKey on factory params,
// even though json_serializable consumes them via the generated .g.dart.
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'journal_entry_model.freezed.dart';
part 'journal_entry_model.g.dart';

/// Mirrors the `journal_entries` table (SPEC §5).
///
/// Note: `linkedHabitLogIds` is a UI-only field — habit logs are joined by
/// `(user_id, log_date)`, not stored on the journal row. It is preserved on
/// JSON round-trip so screens can carry it through state, but
/// [toSupabase] omits it when writing to the DB.
@freezed
class JournalEntryModel with _$JournalEntryModel {
  const JournalEntryModel._();

  const factory JournalEntryModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'entry_date') required DateTime date,
    @JsonKey(name: 'free_text') @Default('') String text,
    int? mood,
    int? energy,
    Map<String, String>? answers,
    @JsonKey(name: 'linked_habit_log_ids')
    @Default(<String>[])
    List<String> linkedHabitLogIds,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _JournalEntryModel;

  factory JournalEntryModel.fromJson(Map<String, dynamic> json) =>
      _$JournalEntryModelFromJson(json);

  /// Build from a Supabase row. Coerces `entry_date` (YYYY-MM-DD) and the
  /// `answers` jsonb into strict Dart types.
  factory JournalEntryModel.fromSupabase(Map<String, dynamic> row) {
    final answersRaw = row['answers'];
    final Map<String, String>? answers = answersRaw is Map
        ? answersRaw.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''))
        : null;
    return JournalEntryModel(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      date: _parseDateOnly(row['entry_date'] as String),
      text: (row['free_text'] as String?) ?? '',
      mood: (row['mood'] as num?)?.toInt(),
      energy: (row['energy'] as num?)?.toInt(),
      answers: answers,
      linkedHabitLogIds: const <String>[],
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  /// Returns a row payload for `journal_entries`. Excludes [linkedHabitLogIds]
  /// (DB has no such column — links are derived from `habit_logs` by date).
  Map<String, dynamic> toSupabase() {
    return <String, dynamic>{
      'id': id,
      'user_id': userId,
      'entry_date': _dateOnly(date),
      'free_text': text,
      'mood': mood,
      'energy': energy,
      'answers': answers,
    };
  }

  bool get isLowMood => mood != null && mood! <= 4;
  bool get isHighMood => mood != null && mood! >= 7;
}

String _dateOnly(DateTime d) {
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${d.year}-$m-$day';
}

/// Parses a `YYYY-MM-DD` Postgres `DATE` value as a UTC midnight DateTime so
/// equality checks are timezone-stable.
DateTime _parseDateOnly(String s) {
  final parts = s.split('-');
  return DateTime.utc(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}
