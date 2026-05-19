import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'journal_entry_model.dart';

/// Thin wrapper around `journal_entries` Supabase table.
///
/// All requests are filtered by `userId` client-side; RLS on the server
/// enforces the same constraint authoritatively.
class JournalRepository {
  JournalRepository({required SupabaseClient client, required String userId})
      : _client = client,
        _userId = userId;

  final SupabaseClient _client;
  final String _userId;

  static const _table = 'journal_entries';

  /// Realtime stream of all entries for the current user, newest first.
  Stream<List<JournalEntryModel>> watchAll() {
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .order('entry_date', ascending: false)
        .map((rows) => rows.map(JournalEntryModel.fromSupabase).toList());
  }

  /// Returns the entry for [date] (date-only, time ignored), or `null`.
  Future<JournalEntryModel?> findByDate(DateTime date) async {
    final iso = _dateOnly(date);
    final row = await _client
        .from(_table)
        .select()
        .eq('user_id', _userId)
        .eq('entry_date', iso)
        .maybeSingle();
    if (row == null) return null;
    return JournalEntryModel.fromSupabase(row);
  }

  /// Inserts or updates by `(user_id, entry_date)`.
  Future<JournalEntryModel> upsert(JournalEntryModel entry) async {
    final payload = entry.toSupabase();
    final row = await _client
        .from(_table)
        .upsert(payload, onConflict: 'user_id,entry_date')
        .select()
        .single();
    return JournalEntryModel.fromSupabase(row);
  }

  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', id).eq('user_id', _userId);
  }

  /// Total entry count for the current user. Used by the summary trigger UI.
  Future<int> totalCount() async {
    final res = await _client
        .from(_table)
        .count(CountOption.exact)
        .eq('user_id', _userId);
    return res;
  }
}

String _dateOnly(DateTime d) {
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${d.year}-$m-$day';
}
