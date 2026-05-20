import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/config/env.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/timezone.dart';
import '../domain/auth_state.dart';

/// Storage keys for the cached session.
const _kJwtKey = 'auth.jwt';
const _kUserKey = 'auth.user';

/// Wraps the `auth_telegram` Edge Function call and the secure-storage cache
/// of the resulting JWT.
///
/// The repository is intentionally framework-agnostic — Riverpod wiring lives
/// in `auth_providers.dart`.
class AuthRepository {
  AuthRepository({
    required SupabaseService supabaseService,
    Dio? dio,
    FlutterSecureStorage? storage,
  })  : _supabase = supabaseService,
        _dio = dio ?? Dio(),
        _storage = storage ?? const FlutterSecureStorage();

  final SupabaseService _supabase;
  final Dio _dio;
  final FlutterSecureStorage _storage;

  String get _endpoint => '${Env.supabaseUrl}/functions/v1/auth_telegram';

  /// Exchange Telegram `initData` for a Supabase JWT and a `users` row.
  ///
  /// On success the JWT is persisted in secure storage and applied to the
  /// active Supabase client. Throws [AuthException] on transport/4xx/5xx —
  /// the caller wraps into [AuthState.failed].
  Future<Authenticated> signInWithTelegram(String initData) async {
    final Response<dynamic> response;
    try {
      response = await _dio.post<dynamic>(
        _endpoint,
        data: <String, dynamic>{'initData': initData},
        options: Options(
          headers: <String, String>{
            'apikey': Env.supabaseAnonKey,
            'Authorization': 'Bearer ${Env.supabaseAnonKey}',
            'Content-Type': 'application/json',
          },
        ),
      );
    } on DioException catch (e) {
      throw AuthException(
        'auth_telegram request failed: ${e.message ?? e.type.name}',
      );
    }

    if (response.statusCode != 200 || response.data is! Map) {
      throw AuthException(
        'auth_telegram returned ${response.statusCode}',
      );
    }

    final body = (response.data as Map).cast<String, dynamic>();
    final jwt = body['jwt'];
    final userJson = body['user'];
    if (jwt is! String || jwt.isEmpty || userJson is! Map) {
      throw const AuthException('auth_telegram returned malformed payload');
    }

    final user = AuthUser.fromJson(userJson.cast<String, dynamic>());

    await _persist(jwt: jwt, user: user);
    await _supabase.applySession(jwt);
    await _syncTimeZone(user.id);

    return Authenticated(jwt: jwt, user: user);
  }

  /// Try to restore a previously saved session. If the JWT is missing or
  /// already expired (with a small leeway), the cache is cleared and we
  /// return [Unauthenticated].
  Future<AuthState> restoreSession() async {
    final jwt = await _storage.read(key: _kJwtKey);
    final userRaw = await _storage.read(key: _kUserKey);
    if (jwt == null || jwt.isEmpty || userRaw == null || userRaw.isEmpty) {
      return const Unauthenticated();
    }

    if (isJwtExpired(jwt)) {
      await _clearStorage();
      return const Unauthenticated();
    }

    final AuthUser user;
    try {
      final decoded = jsonDecode(userRaw);
      if (decoded is! Map) {
        await _clearStorage();
        return const Unauthenticated();
      }
      user = AuthUser.fromJson(decoded.cast<String, dynamic>());
    } catch (_) {
      await _clearStorage();
      return const Unauthenticated();
    }

    try {
      await _supabase.applySession(jwt);
    } catch (e) {
      return Failed(e);
    }
    await _syncTimeZone(user.id);
    return Authenticated(jwt: jwt, user: user);
  }

  /// Best-effort: push the device's IANA timezone into `users.timezone` so
  /// pg_cron `enqueue_due_reminders` fires reminders at the user's local
  /// wall-clock instead of UTC. Never throws — a network blip or a browser
  /// without `Intl` just leaves the previous value in place.
  ///
  /// The `.neq('timezone', tz)` filter turns the call into a no-op when the
  /// row is already correct, so this runs every login without write churn.
  Future<void> _syncTimeZone(String userId) async {
    if (userId.isEmpty) return;
    final tz = detectIanaTimeZone();
    if (tz.isEmpty) return;
    try {
      await _supabase.client
          .from('users')
          .update(<String, dynamic>{'timezone': tz})
          .eq('id', userId)
          .neq('timezone', tz);
    } catch (_) {
      // Reminders just keep firing in the previously-stored zone until the
      // next successful login — acceptable degradation.
    }
  }

  /// Clear cache + sign out from Supabase.
  Future<void> signOut() async {
    await _clearStorage();
    try {
      await _supabase.clearSession();
    } catch (_) {
      // Best-effort — local storage is the source of truth for "signed out".
    }
  }

  Future<void> _persist({required String jwt, required AuthUser user}) async {
    await _storage.write(key: _kJwtKey, value: jwt);
    await _storage.write(key: _kUserKey, value: jsonEncode(user.toJson()));
  }

  Future<void> _clearStorage() async {
    await _storage.delete(key: _kJwtKey);
    await _storage.delete(key: _kUserKey);
  }
}

/// Thrown by [AuthRepository] when the Edge Function returns a non-200 or
/// malformed payload. Distinct from `gotrue.AuthException` — we never import
/// both in the same scope.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => 'AuthException: $message';
}
