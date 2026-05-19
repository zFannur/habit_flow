import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/repository_error.dart';
import '../domain/habit_log_status.dart';
import 'habit_log_model.dart';

/// Thin wrapper around the `habit_logs` Supabase table.
///
/// `(habit_id, log_date)` is unique on the server side, so [log] performs an
/// upsert keyed by that pair. Errors are wrapped into [RepositoryError].
class HabitLogsRepository {
  HabitLogsRepository({
    required SupabaseClient client,
    required String userId,
  })  : _client = client,
        _userId = userId;

  final SupabaseClient _client;
  final String _userId;

  static const _table = 'habit_logs';

  /// Realtime stream of logs for [habitId], newest first.
  Stream<List<HabitLogModel>> watchForHabit(String habitId) {
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('habit_id', habitId)
        .order('log_date', ascending: false)
        .map((rows) => rows.map(HabitLogModel.fromJson).toList())
        .handleError((Object e) => throw RepositoryError.from(e));
  }

  /// Insert-or-update the log for `(habitId, date)`.
  ///
  /// `value` and `comment` are optional and only relevant for countable /
  /// timed habits or when the user attaches a note.
  Future<HabitLogModel> log(
    String habitId,
    DateTime date,
    HabitLogStatus status, {
    num? value,
    String? comment,
  }) async {
    try {
      final payload = <String, dynamic>{
        'user_id': _userId,
        'habit_id': habitId,
        'log_date': _dateOnly(date),
        'status': status.wireName,
        'value': ?value,
        'comment': ?comment,
      };
      final row = await _client
          .from(_table)
          .upsert(payload, onConflict: 'habit_id,log_date')
          .select()
          .single();
      return HabitLogModel.fromJson(row);
    } catch (e) {
      throw RepositoryError.from(e);
    }
  }

  /// Removes a single log row by id (e.g. user "undo" of a check-mark).
  Future<void> undo(String logId) async {
    try {
      await _client
          .from(_table)
          .delete()
          .eq('id', logId)
          .eq('user_id', _userId);
    } catch (e) {
      throw RepositoryError.from(e);
    }
  }

  /// All logs for the current user with `from <= log_date <= to`.
  /// Both bounds are inclusive; only the date part is considered.
  Future<List<HabitLogModel>> rangeForUser(DateTime from, DateTime to) async {
    try {
      final rows = await _client
          .from(_table)
          .select()
          .eq('user_id', _userId)
          .gte('log_date', _dateOnly(from))
          .lte('log_date', _dateOnly(to))
          .order('log_date', ascending: false);
      return (rows as List)
          .cast<Map<String, dynamic>>()
          .map(HabitLogModel.fromJson)
          .toList();
    } catch (e) {
      throw RepositoryError.from(e);
    }
  }
}

String _dateOnly(DateTime d) {
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${d.year.toString().padLeft(4, '0')}-$m-$day';
}
