import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/features/auth/domain/auth_state.dart';

/// Convenience: switch over the sealed [AuthState] without using `as`. If the
/// hierarchy ever grows, the analyzer flags missing branches.
String _describe(AuthState s) => switch (s) {
      Unauthenticated() => 'unauthenticated',
      Authenticated(:final jwt) => 'authenticated:$jwt',
      Failed(:final error) => 'failed:$error',
    };

void main() {
  group('AuthUser.fromJson', () {
    test('parses full payload', () {
      final user = AuthUser.fromJson(<String, dynamic>{
        'id': 'u-1',
        'telegram_user_id': 42,
        'first_name': 'Alex',
        'last_name': 'Doe',
        'telegram_username': 'alex',
        'language': 'ru',
      });

      expect(user.id, 'u-1');
      expect(user.telegramUserId, 42);
      expect(user.firstName, 'Alex');
      expect(user.lastName, 'Doe');
      expect(user.telegramUsername, 'alex');
      expect(user.language, 'ru');
    });

    test('parses minimal payload (id only)', () {
      final user = AuthUser.fromJson(<String, dynamic>{'id': 'u-2'});

      expect(user.id, 'u-2');
      expect(user.telegramUserId, isNull);
      expect(user.firstName, isNull);
      expect(user.lastName, isNull);
      expect(user.telegramUsername, isNull);
      expect(user.language, isNull);
    });

    test('coerces numeric telegram_user_id', () {
      // Edge function may return a JSON number — make sure num.toInt() runs.
      final user = AuthUser.fromJson(<String, dynamic>{
        'id': 'u-3',
        'telegram_user_id': 12345,
      });
      expect(user.telegramUserId, 12345);
    });

    test('toJson omits null optional fields', () {
      const user = AuthUser(id: 'u-4');
      expect(user.toJson(), <String, dynamic>{'id': 'u-4'});
    });

    test('toJson roundtrip preserves populated fields', () {
      const original = AuthUser(
        id: 'u-5',
        telegramUserId: 7,
        firstName: 'Sam',
        language: 'en',
      );
      final restored = AuthUser.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.telegramUserId, original.telegramUserId);
      expect(restored.firstName, original.firstName);
      expect(restored.language, original.language);
    });
  });

  group('AuthState sealed hierarchy', () {
    test('Unauthenticated is its own type', () {
      const state = AuthState.unauthenticated();
      expect(state, isA<Unauthenticated>());
      expect(_describe(state), 'unauthenticated');
    });

    test('Authenticated carries jwt + user', () {
      const user = AuthUser(id: 'u-1', firstName: 'Alex');
      const state = AuthState.authenticated(jwt: 'token.value.sig', user: user);

      expect(state, isA<Authenticated>());
      final auth = state as Authenticated;
      expect(auth.jwt, 'token.value.sig');
      expect(auth.user.id, 'u-1');
      expect(_describe(state), 'authenticated:token.value.sig');
    });

    test('Failed wraps the error object', () {
      final err = Exception('network down');
      final state = AuthState.failed(err);

      expect(state, isA<Failed>());
      final failed = state as Failed;
      expect(failed.error, err);
      expect(_describe(state), startsWith('failed:'));
    });

    test('switch covers all branches without default', () {
      // If a new variant is ever added, this won't compile — that's the point.
      final variants = <AuthState>[
        const AuthState.unauthenticated(),
        const AuthState.authenticated(
          jwt: 'jwt',
          user: AuthUser(id: 'u'),
        ),
        AuthState.failed(StateError('boom')),
      ];

      final descriptions = variants.map(_describe).toList();
      expect(descriptions, hasLength(3));
      expect(descriptions[0], 'unauthenticated');
      expect(descriptions[1], 'authenticated:jwt');
      expect(descriptions[2], startsWith('failed:'));
    });

    test('Failed preserves arbitrary error types (network failure)', () {
      // Simulate the "network error → Failed" path without involving the
      // repository — AuthController wraps any throw in Failed(e).
      final socketLike = Exception('SocketException: connection refused');
      final AuthState state = AuthState.failed(socketLike);

      expect(state, isA<Failed>());
      expect((state as Failed).error.toString(), contains('SocketException'));
    });
  });
}
