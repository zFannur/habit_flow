import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/core/services/supabase_service.dart';
import 'package:habit_flow/features/auth/data/auth_repository.dart';
import 'package:habit_flow/features/auth/domain/auth_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

class _MockSupabaseService extends Mock implements SupabaseService {}

class _FakeOptions extends Fake implements Options {}

/// Build a syntactically valid JWT (header.payload.signature) where the
/// payload encodes the given claims. Signature is a placeholder — we never
/// validate it client-side.
String _makeJwt(Map<String, dynamic> claims) {
  String b64(String s) =>
      base64Url.encode(utf8.encode(s)).replaceAll('=', '');
  final header = b64(jsonEncode({'alg': 'HS256', 'typ': 'JWT'}));
  final payload = b64(jsonEncode(claims));
  return '$header.$payload.signature';
}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeOptions());
  });

  group('AuthRepository.signInWithTelegram', () {
    late _MockDio dio;
    late _MockSecureStorage storage;
    late _MockSupabaseService supabase;
    late AuthRepository repo;

    setUp(() {
      dio = _MockDio();
      storage = _MockSecureStorage();
      supabase = _MockSupabaseService();
      repo = AuthRepository(
        supabaseService: supabase,
        dio: dio,
        storage: storage,
      );

      when(
        () => storage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});
      when(() => supabase.applySession(any())).thenAnswer((_) async {});
    });

    test('saves jwt + user and applies session on 200', () async {
      final jwt = _makeJwt({
        'sub': 'u1',
        'exp': DateTime.now()
                .add(const Duration(hours: 1))
                .millisecondsSinceEpoch ~/
            1000,
      });
      when(
        () => dio.post<dynamic>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: <String, dynamic>{
            'jwt': jwt,
            'user': <String, dynamic>{
              'id': 'u1',
              'telegram_user_id': 42,
              'first_name': 'Alex',
              'language': 'ru',
            },
          },
        ),
      );

      final resultRes = await repo.signInWithTelegram('init=...').run();
      final result = resultRes.getOrElse((f) => fail('signInWithTelegram returned failure: $f'));

      expect(result.jwt, jwt);
      expect(result.user.id, 'u1');
      expect(result.user.firstName, 'Alex');
      expect(result.user.telegramUserId, 42);

      verify(() => storage.write(key: 'auth.jwt', value: jwt)).called(1);
      verify(
        () => storage.write(
          key: 'auth.user',
          value: any(named: 'value', that: contains('"id":"u1"')),
        ),
      ).called(1);
      verify(() => supabase.applySession(jwt)).called(1);
    });

    test('returns Left(Failure.auth) on non-200', () async {
      when(
        () => dio.post<dynamic>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: ''),
          statusCode: 401,
          data: <String, dynamic>{'error': 'unauthorized'},
        ),
      );

      final result = await repo.signInWithTelegram('init=...').run();
      expect(result.isLeft(), isTrue);

      verifyNever(
        () => storage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      );
      verifyNever(() => supabase.applySession(any()));
    });

    test('returns Left(Failure.unknown) on malformed payload', () async {
      when(
        () => dio.post<dynamic>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: <String, dynamic>{'jwt': '', 'user': null},
        ),
      );

      final result = await repo.signInWithTelegram('init=...').run();
      expect(result.isLeft(), isTrue);
    });

    test('returns Left(Failure.network) on DioException', () async {
      when(
        () => dio.post<dynamic>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionError,
        ),
      );

      final result = await repo.signInWithTelegram('init=...').run();
      expect(result.isLeft(), isTrue);
    });
  });

  group('AuthRepository.restoreSession', () {
    late _MockDio dio;
    late _MockSecureStorage storage;
    late _MockSupabaseService supabase;
    late AuthRepository repo;

    setUp(() {
      dio = _MockDio();
      storage = _MockSecureStorage();
      supabase = _MockSupabaseService();
      repo = AuthRepository(
        supabaseService: supabase,
        dio: dio,
        storage: storage,
      );
      when(
        () => storage.delete(key: any(named: 'key')),
      ).thenAnswer((_) async {});
      when(() => supabase.applySession(any())).thenAnswer((_) async {});
    });

    test('Unauthenticated when nothing in storage', () async {
      when(
        () => storage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => null);

      final state = await repo.restoreSession();
      expect(state, isA<Unauthenticated>());
      verifyNever(() => supabase.applySession(any()));
    });

    test('Unauthenticated and storage cleared when JWT expired', () async {
      final expiredJwt = _makeJwt({
        'sub': 'u1',
        'exp': DateTime.now()
                .subtract(const Duration(hours: 1))
                .millisecondsSinceEpoch ~/
            1000,
      });
      when(() => storage.read(key: 'auth.jwt'))
          .thenAnswer((_) async => expiredJwt);
      when(() => storage.read(key: 'auth.user')).thenAnswer(
        (_) async => jsonEncode({'id': 'u1'}),
      );

      final state = await repo.restoreSession();

      expect(state, isA<Unauthenticated>());
      verify(() => storage.delete(key: 'auth.jwt')).called(1);
      verify(() => storage.delete(key: 'auth.user')).called(1);
      verifyNever(() => supabase.applySession(any()));
    });

    test('Authenticated and applies session when JWT still valid', () async {
      final validJwt = _makeJwt({
        'sub': 'u1',
        'exp': DateTime.now()
                .add(const Duration(hours: 1))
                .millisecondsSinceEpoch ~/
            1000,
      });
      when(() => storage.read(key: 'auth.jwt'))
          .thenAnswer((_) async => validJwt);
      when(() => storage.read(key: 'auth.user')).thenAnswer(
        (_) async => jsonEncode({'id': 'u1', 'first_name': 'Alex'}),
      );

      final state = await repo.restoreSession();

      expect(state, isA<Authenticated>());
      final auth = state as Authenticated;
      expect(auth.jwt, validJwt);
      expect(auth.user.id, 'u1');
      verify(() => supabase.applySession(validJwt)).called(1);
    });

    test('Unauthenticated when stored user JSON is corrupt', () async {
      final validJwt = _makeJwt({
        'sub': 'u1',
        'exp': DateTime.now()
                .add(const Duration(hours: 1))
                .millisecondsSinceEpoch ~/
            1000,
      });
      when(() => storage.read(key: 'auth.jwt'))
          .thenAnswer((_) async => validJwt);
      when(() => storage.read(key: 'auth.user'))
          .thenAnswer((_) async => 'not-json{{{');

      final state = await repo.restoreSession();

      expect(state, isA<Unauthenticated>());
      verify(() => storage.delete(key: 'auth.jwt')).called(1);
      verify(() => storage.delete(key: 'auth.user')).called(1);
    });
  });

  group('AuthRepository.signOut', () {
    test('clears storage and calls supabase.clearSession', () async {
      final dio = _MockDio();
      final storage = _MockSecureStorage();
      final supabase = _MockSupabaseService();
      final repo = AuthRepository(
        supabaseService: supabase,
        dio: dio,
        storage: storage,
      );

      when(() => storage.delete(key: any(named: 'key')))
          .thenAnswer((_) async {});
      when(() => supabase.clearSession()).thenAnswer((_) async {});

      await repo.signOut().run();

      verify(() => storage.delete(key: 'auth.jwt')).called(1);
      verify(() => storage.delete(key: 'auth.user')).called(1);
      verify(() => supabase.clearSession()).called(1);
    });

    test('survives Supabase signOut throwing', () async {
      final dio = _MockDio();
      final storage = _MockSecureStorage();
      final supabase = _MockSupabaseService();
      final repo = AuthRepository(
        supabaseService: supabase,
        dio: dio,
        storage: storage,
      );

      when(() => storage.delete(key: any(named: 'key')))
          .thenAnswer((_) async {});
      when(() => supabase.clearSession())
          .thenThrow(StateError('already signed out'));

      await repo.signOut().run(); // must not throw
      verify(() => storage.delete(key: 'auth.jwt')).called(1);
    });
  });

  group('isJwtExpired', () {
    test('true for malformed JWT', () {
      expect(isJwtExpired('not.a.jwt'), isTrue);
      expect(isJwtExpired(''), isTrue);
    });

    test('true for past exp', () {
      final past = _makeJwt({
        'exp': DateTime.now()
                .subtract(const Duration(minutes: 1))
                .millisecondsSinceEpoch ~/
            1000,
      });
      expect(isJwtExpired(past), isTrue);
    });

    test('false for future exp', () {
      final future = _makeJwt({
        'exp': DateTime.now()
                .add(const Duration(hours: 1))
                .millisecondsSinceEpoch ~/
            1000,
      });
      expect(isJwtExpired(future), isFalse);
    });
  });
}
