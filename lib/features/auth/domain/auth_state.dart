/// Authentication state surfaced to the UI layer.
///
/// Consumed by routing (splash decides where to redirect) and any feature
/// that needs the raw JWT or user payload.
sealed class AuthState {
  const AuthState();

  const factory AuthState.unauthenticated() = Unauthenticated;
  const factory AuthState.authenticated({
    required String jwt,
    required AuthUser user,
  }) = Authenticated;
  const factory AuthState.failed(Object error) = Failed;
}

final class Unauthenticated extends AuthState {
  const Unauthenticated();
}

final class Authenticated extends AuthState {
  const Authenticated({required this.jwt, required this.user});

  final String jwt;
  final AuthUser user;
}

final class Failed extends AuthState {
  const Failed(this.error);

  final Object error;
}

/// Slim mirror of `public.users` row returned by the `auth_telegram` Edge
/// Function. Keep it permissive — we do not own the schema here, the function
/// might add columns.
class AuthUser {
  const AuthUser({
    required this.id,
    this.telegramUserId,
    this.firstName,
    this.lastName,
    this.telegramUsername,
    this.language,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      telegramUserId: (json['telegram_user_id'] as num?)?.toInt(),
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      telegramUsername: json['telegram_username'] as String?,
      language: json['language'] as String?,
    );
  }

  final String id;
  final int? telegramUserId;
  final String? firstName;
  final String? lastName;
  final String? telegramUsername;
  final String? language;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        if (telegramUserId != null) 'telegram_user_id': telegramUserId,
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (telegramUsername != null) 'telegram_username': telegramUsername,
        if (language != null) 'language': language,
      };
}
