import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/app.dart';
import 'package:habit_flow/core/services/locale_service.dart';
import 'package:habit_flow/core/services/supabase_service.dart';
import 'package:habit_flow/core/services/telegram_service.dart';
import 'package:habit_flow/core/services/theme_service.dart';
import 'package:habit_flow/features/auth/data/auth_providers.dart';
import 'package:habit_flow/features/auth/data/auth_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeTelegramService extends TelegramService {
  const _FakeTelegramService(this._initData);

  final String _initData;

  @override
  String getInitData() => _initData;
}

class _MockDio extends Mock implements Dio {}

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

class _MockSupabaseService extends Mock implements SupabaseService {}

class _FakeOptions extends Fake implements Options {}

/// Build a syntactically valid JWT (header.payload.signature) where the
/// payload encodes the given claims. Signature is a placeholder.
String _makeJwt(Map<String, dynamic> claims) {
  String b64(String s) =>
      base64Url.encode(utf8.encode(s)).replaceAll('=', '');
  final header = b64(jsonEncode({'alg': 'HS256', 'typ': 'JWT'}));
  final payload = b64(jsonEncode(claims));
  return '$header.$payload.signature';
}

/// Override bundle that swaps every external dependency the splash flow
/// touches with predictable fakes — Telegram service, secure storage,
/// Supabase session, and the Dio transport that talks to `auth_telegram`.
List<Override> _authOverrides({
  required String initData,
  required Dio dio,
  required FlutterSecureStorage storage,
  required SupabaseService supabase,
}) {
  return [
    telegramServiceProvider.overrideWithValue(_FakeTelegramService(initData)),
    supabaseServiceProvider.overrideWithValue(supabase),
    authRepositoryProvider.overrideWith(
      (_) => AuthRepository(
        supabaseService: supabase,
        dio: dio,
        storage: storage,
      ),
    ),
  ];
}

Future<Widget> _buildApp({
  required String initData,
  required Dio dio,
  required FlutterSecureStorage storage,
  required SupabaseService supabase,
  Map<String, Object> prefs = const <String, Object>{},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  final localeNotifier = await LocaleNotifier.create(sp);
  final themeNotifier = await ThemeNotifier.create(sp);

  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sp),
      localeProvider.overrideWith((_) => localeNotifier),
      themeProvider.overrideWith((_) => themeNotifier),
      ..._authOverrides(
        initData: initData,
        dio: dio,
        storage: storage,
        supabase: supabase,
      ),
    ],
    child: const HabitFlowApp(),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeOptions());
  });

  group('Auth flow', () {
    late _MockDio dio;
    late _MockSecureStorage storage;
    late _MockSupabaseService supabase;

    setUp(() {
      dio = _MockDio();
      storage = _MockSecureStorage();
      supabase = _MockSupabaseService();

      when(() => storage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          )).thenAnswer((_) async {});
      when(() => storage.delete(key: any(named: 'key')))
          .thenAnswer((_) async {});
      when(() => supabase.applySession(any())).thenAnswer((_) async {});
      when(() => supabase.clearSession()).thenAnswer((_) async {});
    });

    testWidgets('happy: valid initData + 200 from auth_telegram → /today',
        (tester) async {
      // No prior session in storage — splash will go through signIn().
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);

      final jwt = _makeJwt({
        'sub': 'u1',
        'exp': DateTime.now()
                .add(const Duration(hours: 1))
                .millisecondsSinceEpoch ~/
            1000,
      });
      when(() => dio.post<dynamic>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer(
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

      final app = await _buildApp(
        initData: 'query_id=1&user=...&hash=abc',
        dio: dio,
        storage: storage,
        supabase: supabase,
        prefs: const <String, Object>{'seen_onboarding': true},
      );

      await tester.pumpWidget(app);
      // Pump several frames: splash post-frame callback → signIn → router
      // refresh → redirect → /today.
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify the auth_telegram call carried the initData payload.
      verify(() => dio.post<dynamic>(
            any(that: contains('/functions/v1/auth_telegram')),
            data: any(
              named: 'data',
              that: predicate<Object?>(
                (d) => d is Map && d['initData'] == 'query_id=1&user=...&hash=abc',
              ),
            ),
            options: any(named: 'options'),
          )).called(1);

      // Storage write happened with the JWT.
      verify(() => storage.write(key: 'auth.jwt', value: jwt)).called(1);
      verify(() => supabase.applySession(jwt)).called(1);
    });

    testWidgets('expired JWT in storage → re-auth via initData → /today',
        (tester) async {
      // Storage contains a past-exp JWT — restoreSession() must drop it and
      // splash should kick off signIn() with the fresh initData.
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
        (_) async => jsonEncode({'id': 'u1', 'first_name': 'Alex'}),
      );

      final freshJwt = _makeJwt({
        'sub': 'u1',
        'exp': DateTime.now()
                .add(const Duration(hours: 1))
                .millisecondsSinceEpoch ~/
            1000,
      });
      when(() => dio.post<dynamic>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: <String, dynamic>{
            'jwt': freshJwt,
            'user': <String, dynamic>{'id': 'u1', 'first_name': 'Alex'},
          },
        ),
      );

      final app = await _buildApp(
        initData: 'init=valid',
        dio: dio,
        storage: storage,
        supabase: supabase,
        prefs: const <String, Object>{'seen_onboarding': true},
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Expired token must be cleared from storage by restoreSession.
      verify(() => storage.delete(key: 'auth.jwt')).called(greaterThanOrEqualTo(1));
      verify(() => storage.delete(key: 'auth.user'))
          .called(greaterThanOrEqualTo(1));

      // Splash then exchanged the new initData for a fresh JWT.
      verify(() => dio.post<dynamic>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).called(1);
      verify(() => storage.write(key: 'auth.jwt', value: freshJwt)).called(1);
      verify(() => supabase.applySession(freshJwt)).called(1);
    });

    testWidgets('network error during sign-in surfaces error UI',
        (tester) async {
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);
      when(() => dio.post<dynamic>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionError,
        ),
      );

      final app = await _buildApp(
        initData: 'init=valid',
        dio: dio,
        storage: storage,
        supabase: supabase,
        prefs: const <String, Object>{'seen_onboarding': true},
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // The error icon is rendered by SplashScreen on Failed state.
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      verifyNever(() => storage.write(
            key: 'auth.jwt',
            value: any(named: 'value'),
          ));
      verifyNever(() => supabase.applySession(any()));
    });
  });
}
