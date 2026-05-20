import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/failure.dart';
import '../../../core/errors/result.dart';
import '../../journal/data/journal_providers.dart';
import '../domain/style_prompts.dart';

/// Repository to persist/retrieve the user's chosen AI personality style in `users.ai_style`.
class AiStyleRepository {
  AiStyleRepository(this._client, this._userId);

  final SupabaseClient _client;
  final String _userId;

  AppTask<AiStyle> load() {
    return TaskEither.tryCatch(
      () async {
        final row = await _client
            .from('users')
            .select('ai_style')
            .eq('id', _userId)
            .maybeSingle();
        final raw = row?['ai_style']?.toString();
        return AiStyle.fromWire(raw);
      },
      (e, st) => Failure.unknown(message: e.toString()),
    );
  }

  AppTask<void> update(AiStyle style) {
    return TaskEither.tryCatch(
      () async {
        await _client
            .from('users')
            .update({'ai_style': style.wireName})
            .eq('id', _userId);
      },
      (e, st) => Failure.unknown(message: e.toString()),
    );
  }
}

/// Provider for AiStyleRepository.
final aiStyleRepositoryProvider = Provider<AiStyleRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final userId = ref.watch(currentUserIdProvider);
  return AiStyleRepository(client, userId);
});

/// Persists the user's chosen AI personality style in `users.ai_style`.
///
/// Mirrors [PreferredModelController] (see `openrouter_models_repository.dart`)
/// so the settings screen has a single, predictable persistence pattern.
class AiStyleController extends StateNotifier<AsyncValue<AiStyle>> {
  AiStyleController(this._repository) : super(const AsyncValue.loading()) {
    _bootstrap();
  }

  final AiStyleRepository _repository;

  Future<void> _bootstrap() async {
    final res = await _repository.load().run();
    res.match(
      (f) => state = AsyncValue.error(f, StackTrace.current),
      (style) => state = AsyncValue.data(style),
    );
  }

  /// Optimistically apply [style] and persist it. Locked styles (Poet
  /// for non-supporters) must be filtered by the UI before calling.
  Future<void> select(AiStyle style) async {
    state = AsyncValue.data(style);
    final res = await _repository.update(style).run();
    res.match(
      (f) => state = AsyncValue.error(f, StackTrace.current),
      (_) => null,
    );
  }
}

/// Active AI style for the signed-in user (`users.ai_style`).
final aiStyleControllerProvider =
    StateNotifierProvider<AiStyleController, AsyncValue<AiStyle>>((ref) {
  final repository = ref.watch(aiStyleRepositoryProvider);
  return AiStyleController(repository);
});
