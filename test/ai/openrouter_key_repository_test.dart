import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/features/ai/data/openrouter_key_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

class _MockDio extends Mock implements Dio {}

class _FakeRequestOptions extends Fake implements RequestOptions {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeRequestOptions());
    registerFallbackValue(Options());
  });

  group('OpenRouterKeyRepository — secure storage', () {
    late _MockSecureStorage storage;
    late _MockDio dio;
    late OpenRouterKeyRepository repo;

    setUp(() {
      storage = _MockSecureStorage();
      dio = _MockDio();
      repo = OpenRouterKeyRepository(storage: storage, dio: dio);
    });

    test('save() пишет ключ под ожидаемым именем', () async {
      when(
        () => storage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      await repo.save('sk-or-v1-test').run();

      verify(
        () => storage.write(key: 'openrouter_key', value: 'sk-or-v1-test'),
      ).called(1);
    });

    test('load() возвращает значение из storage', () async {
      when(
        () => storage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => 'sk-or-v1-stored');

      final valueRes = await repo.load().run();
      final value = valueRes.getOrElse((_) => null);

      expect(value, 'sk-or-v1-stored');
      verify(() => storage.read(key: 'openrouter_key')).called(1);
    });

    test('load() возвращает null если ничего нет', () async {
      when(
        () => storage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => null);

      final valueRes = await repo.load().run();
      expect(valueRes.getOrElse((_) => 'fallback'), isNull);
    });

    test('clear() удаляет запись', () async {
      when(
        () => storage.delete(key: any(named: 'key')),
      ).thenAnswer((_) async {});

      await repo.clear().run();

      verify(() => storage.delete(key: 'openrouter_key')).called(1);
    });
  });

  group('OpenRouterKeyRepository — isValid', () {
    late _MockSecureStorage storage;
    late _MockDio dio;
    late OpenRouterKeyRepository repo;

    setUp(() {
      storage = _MockSecureStorage();
      dio = _MockDio();
      repo = OpenRouterKeyRepository(storage: storage, dio: dio);
    });

    test('200 → isValid = true', () async {
      when(
        () => dio.get<dynamic>(
          any(),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (invocation) async => Response<dynamic>(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: {'data': []},
        ),
      );

      final okRes = await repo.isValid(key: 'sk-or-v1-good').run();
      expect(okRes.getOrElse((_) => false), isTrue);
    });

    test('401 → isValid = false', () async {
      when(
        () => dio.get<dynamic>(
          any(),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (invocation) async => Response<dynamic>(
          requestOptions: RequestOptions(path: ''),
          statusCode: 401,
          data: {'error': 'invalid'},
        ),
      );

      final okRes = await repo.isValid(key: 'sk-or-v1-bad').run();
      expect(okRes.getOrElse((_) => false), isFalse);
    });

    test('DioException → isValid = false', () async {
      when(
        () => dio.get<dynamic>(
          any(),
          options: any(named: 'options'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionError,
        ),
      );

      final okRes = await repo.isValid(key: 'sk-or-v1-x').run();
      expect(okRes.getOrElse((_) => false), isFalse);
    });

    test('пустой ключ → isValid = false без HTTP-вызова', () async {
      when(
        () => storage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => null);

      final okRes = await repo.isValid().run();
      expect(okRes.getOrElse((_) => false), isFalse);

      verifyNever(
        () => dio.get<dynamic>(
          any(),
          options: any(named: 'options'),
        ),
      );
    });
  });
}
