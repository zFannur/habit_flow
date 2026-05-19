import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/repository_error.dart';
import 'habit_model.dart';

/// Thin wrapper around the `habits` Supabase table.
///
/// All requests are filtered client-side by `user_id`; RLS on the server
/// enforces the same constraint authoritatively. Errors are wrapped into
/// [RepositoryError] so the UI can branch on `kind` rather than raw types.
class HabitsRepository {
  HabitsRepository({required SupabaseClient client, required String userId})
      : _client = client,
        _userId = userId;

  final SupabaseClient _client;
  final String _userId;

  static const _table = 'habits';

  /// Realtime stream of all habits for [userId], ordered by `position`.
  ///
  /// Note: [userId] argument is exposed for API symmetry with the SPEC, but
  /// streams always run against the constructor-bound `_userId`. Asking for a
  /// different user is an error.
  Stream<List<HabitModel>> watchAll(String userId) {
    if (userId != _userId) {
      return Stream<List<HabitModel>>.error(
        const RepositoryUnauthorizedError(
          message: 'Cannot stream habits for a different user',
        ),
      );
    }
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .order('position')
        .map((rows) => rows.map(HabitModel.fromJson).toList())
        .handleError((Object e) => throw RepositoryError.from(e));
  }

  /// Habits scheduled to be visible on [date], excluding archived ones.
  ///
  /// Cadence is evaluated client-side via [HabitModel.isToday] which honours
  /// `daily`, `weekdays`, `every_n_days`, `monthly_dates` and `n_per_week`.
  Future<List<HabitModel>> listForToday(DateTime date) async {
    try {
      final rows = await _client
          .from(_table)
          .select()
          .eq('user_id', _userId)
          .eq('is_archived', false)
          .order('position');
      final all = (rows as List)
          .cast<Map<String, dynamic>>()
          .map(HabitModel.fromJson);
      return all.where((h) => h.isToday(date)).toList();
    } catch (e) {
      throw RepositoryError.from(e);
    }
  }

  /// Inserts a new habit row and returns the persisted version.
  Future<HabitModel> create(HabitModel habit) async {
    try {
      final payload = habit.toJson()
        ..remove('created_at')
        ..remove('updated_at')
        ..remove('category_id'); // not a column in habits — joined from habit_categories
      payload['user_id'] = _userId;
      // Empty id → let DB generate via gen_random_uuid().
      final id = payload['id'];
      if (id == null || (id is String && id.isEmpty)) {
        payload.remove('id');
      }
      final row = await _client
          .from(_table)
          .insert(payload)
          .select()
          .single();
      return HabitModel.fromJson(row);
    } catch (e) {
      throw RepositoryError.from(e);
    }
  }

  /// Updates [habit] by id and returns the updated row.
  Future<HabitModel> update(HabitModel habit) async {
    try {
      final payload = habit.toJson()
        ..remove('created_at')
        ..remove('updated_at')
        ..remove('id');
      final row = await _client
          .from(_table)
          .update(payload)
          .eq('id', habit.id)
          .eq('user_id', _userId)
          .select()
          .single();
      return HabitModel.fromJson(row);
    } catch (e) {
      throw RepositoryError.from(e);
    }
  }

  /// Soft-archive: flips `is_archived = true`. Logs are preserved.
  Future<void> archive(String id) async {
    try {
      await _client
          .from(_table)
          .update({'is_archived': true})
          .eq('id', id)
          .eq('user_id', _userId);
    } catch (e) {
      throw RepositoryError.from(e);
    }
  }

  /// Hard-delete. `ON DELETE CASCADE` removes any associated logs.
  Future<void> delete(String id) async {
    try {
      await _client
          .from(_table)
          .delete()
          .eq('id', id)
          .eq('user_id', _userId);
    } catch (e) {
      throw RepositoryError.from(e);
    }
  }
}
