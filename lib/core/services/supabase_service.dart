import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin wrapper around the global [Supabase] singleton that owns our
/// app-specific session lifecycle.
///
/// The `auth_telegram` Edge Function returns a fully-formed access JWT (no
/// refresh token — Telegram initData *is* our refresh mechanism). We feed it
/// to gotrue via [GoTrueClient.recoverSession] using a synthetic Session JSON
/// so PostgREST picks up the bearer token automatically.
class SupabaseService {
  SupabaseService(this._client);

  final SupabaseClient _client;

  SupabaseClient get client => _client;

  /// Pushes [jwt] into the gotrue auth state so all subsequent PostgREST and
  /// Realtime calls carry it as `Authorization: Bearer ...`.
  ///
  /// We pass a refresh token equal to the access token only because gotrue
  /// requires *some* non-empty value; the token will never actually be used
  /// for refresh — we re-issue via `auth_telegram` instead.
  Future<void> applySession(String jwt) async {
    final claims = _decodeJwtPayload(jwt);
    final exp = claims['exp'];
    final expiresAt = exp is int ? exp : (exp is num ? exp.toInt() : 0);
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final expiresIn = expiresAt > nowSec ? (expiresAt - nowSec) : 0;
    final userId = (claims['sub'] as String?) ?? '';

    final sessionJson = <String, dynamic>{
      'access_token': jwt,
      'token_type': 'bearer',
      'expires_in': expiresIn,
      'expires_at': expiresAt,
      'refresh_token': jwt,
      'user': <String, dynamic>{
        'id': userId,
        'aud': claims['aud'] ?? 'authenticated',
        'role': claims['role'] ?? 'authenticated',
        'app_metadata': <String, dynamic>{},
        'user_metadata': <String, dynamic>{},
        'created_at': DateTime.fromMillisecondsSinceEpoch(0).toIso8601String(),
      },
    };

    await _client.auth.recoverSession(jsonEncode(sessionJson));
  }

  /// Drops the current gotrue session both locally and on the server.
  Future<void> clearSession() async {
    await _client.auth.signOut();
  }
}

/// Decode the payload of a JWT (`header.payload.signature`). Returns an
/// empty map if the token is malformed — callers fall back to "expired".
Map<String, dynamic> _decodeJwtPayload(String jwt) {
  final parts = jwt.split('.');
  if (parts.length != 3) return const <String, dynamic>{};
  try {
    final payload = parts[1];
    final normalised = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalised));
    final json = jsonDecode(decoded);
    if (json is Map<String, dynamic>) return json;
    return const <String, dynamic>{};
  } catch (_) {
    return const <String, dynamic>{};
  }
}

/// Returns true if [jwt] has an `exp` claim in the past (or is malformed).
bool isJwtExpired(String jwt, {Duration leeway = const Duration(seconds: 30)}) {
  final claims = _decodeJwtPayload(jwt);
  final exp = claims['exp'];
  final expSec = exp is int ? exp : (exp is num ? exp.toInt() : null);
  if (expSec == null) return true;
  final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  return nowSec >= (expSec - leeway.inSeconds);
}
