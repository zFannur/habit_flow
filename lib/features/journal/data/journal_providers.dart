import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'journal_entry_model.dart';
import 'journal_repository.dart';

/// Exposes the active [SupabaseClient]. Override in tests to supply a mock.
final supabaseClientProvider = Provider<SupabaseClient>(
  (_) => Supabase.instance.client,
);

/// Resolves the authenticated user id, or `''` (empty) when no session is
/// active. Returning empty instead of throwing lets data providers stay
/// alive across the splash → auth race; their queries become
/// `.eq('user_id', '')` which trivially returns 0 rows under RLS — no crash.
///
/// Callers that need a *real* id (e.g. wizards that submit) should check
/// [isAuthenticatedProvider] first.
final currentUserIdProvider = Provider<String>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final id = client.auth.currentUser?.id;
  if (id == null) {
    debugPrint('currentUserIdProvider: no authenticated user yet');
    return '';
  }
  return id;
});

/// `true` when there's a live Supabase session. UI guards (splash, write
/// flows) should branch on this.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserIdProvider).isNotEmpty;
});

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepository(
    client: ref.watch(supabaseClientProvider),
    userId: ref.watch(currentUserIdProvider),
  );
});

/// Realtime list of journal entries for the current user (newest first).
final journalEntriesProvider = StreamProvider<List<JournalEntryModel>>((ref) {
  return ref.watch(journalRepositoryProvider).watchAll();
});

/// Total entry count — used by the counter card and summary trigger UI.
final journalEntryCountProvider = FutureProvider<int>((ref) {
  return ref.watch(journalRepositoryProvider).totalCount();
});

/// Today's journal entry, or `null` when not yet written. Drives the Today
/// screen CTA visibility and the journal list "open today" branch. Derived
/// from [journalEntriesProvider] so it inherits the realtime stream.
final journalTodayEntryProvider = Provider<JournalEntryModel?>((ref) {
  final entriesAsync = ref.watch(journalEntriesProvider);
  final entries = entriesAsync.valueOrNull;
  if (entries == null || entries.isEmpty) return null;
  final now = DateTime.now();
  for (final e in entries) {
    if (e.date.year == now.year &&
        e.date.month == now.month &&
        e.date.day == now.day) {
      return e;
    }
  }
  return null;
});

/// Consecutive days (streak) the user has at least one journal entry.
/// Counts backwards from today: stops at the first day with no entry.
final journalStreakProvider = Provider<int>((ref) {
  final entriesAsync = ref.watch(journalEntriesProvider);
  return entriesAsync.when(
    data: (entries) {
      if (entries.isEmpty) return 0;
      // Build a set of date strings YYYY-MM-DD for O(1) lookup.
      final dateSet = <String>{};
      for (final e in entries) {
        final d = e.date;
        final m = d.month.toString().padLeft(2, '0');
        final day = d.day.toString().padLeft(2, '0');
        dateSet.add('${d.year}-$m-$day');
      }
      var streak = 0;
      var cursor = DateTime.now().toUtc();
      while (true) {
        final m = cursor.month.toString().padLeft(2, '0');
        final day = cursor.day.toString().padLeft(2, '0');
        final key = '${cursor.year}-$m-$day';
        if (!dateSet.contains(key)) break;
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      }
      return streak;
    },
    loading: () => 0,
    error: (_, _) => 0,
  );
});
