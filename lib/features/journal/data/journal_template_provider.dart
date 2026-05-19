import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/locale_service.dart' show sharedPreferencesProvider;

const _prefsKey = 'journal.template';

/// Persisted list of reflection questions used in journal_edit_screen.
/// Stored locally (no DB column yet — SPEC §10.2 leaves this user-local).
/// `null` state means "use default questions baked into ARB".
class JournalTemplateNotifier extends StateNotifier<List<String>?> {
  JournalTemplateNotifier(this._prefs, List<String>? initial) : super(initial);

  final SharedPreferences _prefs;

  static Future<JournalTemplateNotifier> create(SharedPreferences prefs) async {
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return JournalTemplateNotifier(prefs, null);
    try {
      final list = (jsonDecode(raw) as List).cast<String>();
      return JournalTemplateNotifier(prefs, list);
    } catch (_) {
      return JournalTemplateNotifier(prefs, null);
    }
  }

  Future<void> save(List<String> questions) async {
    final clean = questions
        .map((q) => q.trim())
        .where((q) => q.isNotEmpty)
        .toList(growable: false);
    state = clean;
    await _prefs.setString(_prefsKey, jsonEncode(clean));
  }

  Future<void> reset() async {
    state = null;
    await _prefs.remove(_prefsKey);
  }
}

final journalTemplateProvider =
    StateNotifierProvider<JournalTemplateNotifier, List<String>?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  // Provider is sync — initialise lazily via the cached value already loaded
  // in main(). The cached prefs get the raw JSON string instantly.
  final raw = prefs.getString(_prefsKey);
  List<String>? initial;
  if (raw != null) {
    try {
      initial = (jsonDecode(raw) as List).cast<String>();
    } catch (_) {
      initial = null;
    }
  }
  return JournalTemplateNotifier(prefs, initial);
});
