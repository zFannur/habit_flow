import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../journal/data/journal_providers.dart';
import '../domain/style_prompts.dart';

/// Persists the user's chosen AI personality style in `users.ai_style`.
///
/// Mirrors [PreferredModelController] (see `openrouter_models_repository.dart`)
/// so the settings screen has a single, predictable persistence pattern.
class AiStyleController extends StateNotifier<AsyncValue<AiStyle>> {
  AiStyleController(this._client, this._userId)
      : super(const AsyncValue.loading()) {
    _bootstrap();
  }

  final SupabaseClient _client;
  final String _userId;

  Future<void> _bootstrap() async {
    try {
      final row = await _client
          .from('users')
          .select('ai_style')
          .eq('id', _userId)
          .maybeSingle();
      final raw = row?['ai_style']?.toString();
      state = AsyncValue.data(AiStyle.fromWire(raw));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Optimistically apply [style] and persist it. Locked styles (Poet
  /// for non-supporters) must be filtered by the UI before calling.
  Future<void> select(AiStyle style) async {
    state = AsyncValue.data(style);
    try {
      await _client
          .from('users')
          .update({'ai_style': style.wireName})
          .eq('id', _userId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Active AI style for the signed-in user (`users.ai_style`).
final aiStyleControllerProvider =
    StateNotifierProvider<AiStyleController, AsyncValue<AiStyle>>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final userId = ref.watch(currentUserIdProvider);
  return AiStyleController(client, userId);
});
