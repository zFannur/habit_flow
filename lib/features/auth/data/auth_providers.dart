import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import '../../../core/errors/failure.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/telegram_service.dart';
import '../domain/auth_state.dart';
import 'auth_repository.dart';

/// Exposes the active [SupabaseService]. Override in tests.
final supabaseServiceProvider = Provider<SupabaseService>((_) {
  return SupabaseService(Supabase.instance.client);
});

/// Exposes the [TelegramService] singleton. Override in tests to inject a fake.
final telegramServiceProvider = Provider<TelegramService>((_) {
  return const TelegramService();
});

/// Singleton repository — talks to `auth_telegram` and secure storage.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(supabaseService: ref.watch(supabaseServiceProvider));
});

/// Mutable [AuthState] surfaced to the UI. The splash screen drives it via
/// [AuthController.bootstrap] and [AuthController.signIn].
class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repo) : super(const Unauthenticated());

  final AuthRepository _repo;

  /// On app start: try to restore a saved session. Sets state to
  /// [Authenticated], [Unauthenticated], or [Failed].
  Future<void> bootstrap() async {
    try {
      state = await _repo.restoreSession();
    } catch (e) {
      state = Failed(Failure.unknown(message: e.toString()));
    }
  }

  /// Exchange Telegram initData for a fresh JWT.
  Future<void> signIn(String initData) async {
    final res = await _repo.signInWithTelegram(initData).run();
    res.match(
      (f) => state = Failed(f),
      (ok) => state = ok,
    );
  }

  Future<void> signOut() async {
    await _repo.signOut().run();
    state = const Unauthenticated();
  }
}

final authStateProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});
