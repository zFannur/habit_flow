import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:habit_flow/core/services/telegram_service.dart';
import 'package:habit_flow/features/auth/data/auth_providers.dart';
import 'package:habit_flow/features/auth/data/auth_repository.dart';
import 'package:habit_flow/features/auth/data/device_link_repository.dart';
import 'package:habit_flow/features/auth/domain/auth_state.dart';
import 'package:habit_flow/features/auth/domain/device_link_state.dart';
import 'package:habit_flow/features/auth/presentation/device_link_controller.dart';

class _MockDio extends Mock implements Dio {}
class _MockAuthRepository extends Mock implements AuthRepository {}
class _MockAuthController extends Mock implements AuthController {}
class _MockTelegramService extends Mock implements TelegramService {}
class _FakeOptions extends Fake implements Options {}

class _MockDeviceLinkRepository extends Mock implements DeviceLinkRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeOptions());
    registerFallbackValue(const Unauthenticated());
  });

  group('DeviceLinkRepository', () {
    late _MockDio dio;
    late DeviceLinkRepository repository;

    setUp(() {
      dio = _MockDio();
      repository = DeviceLinkRepository(dio: dio);
    });

    test('createToken returns DeviceLinkResponse on 200', () async {
      final expires = DateTime.now().add(const Duration(minutes: 10));
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
            'token': 't_123',
            'deepLink': 'https://t.me/bot?start=link_t_123',
            'expiresAt': expires.toIso8601String(),
          },
        ),
      );

      final result = await repository.createToken();
      expect(result.token, 't_123');
      expect(result.deepLink, 'https://t.me/bot?start=link_t_123');
      expect(result.expiresAt.year, expires.year);
    });

    test('pollToken returns success status on linked response', () async {
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
            'status': 'linked',
            'jwt': 'jwt_secret',
            'user': <String, dynamic>{
              'id': 'u1',
              'telegram_user_id': 123,
            },
          },
        ),
      );

      final result = await repository.pollToken('t_123');
      expect(result, isA<DeviceLinkPollSuccess>());
      final success = result as DeviceLinkPollSuccess;
      expect(success.jwt, 'jwt_secret');
      expect(success.user.id, 'u1');
    });

    test('pollToken returns pending status', () async {
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
          data: <String, dynamic>{'status': 'pending'},
        ),
      );

      final result = await repository.pollToken('t_123');
      expect(result, isA<DeviceLinkPollPending>());
    });

    test('pollToken returns rate limited on 429', () async {
      when(
        () => dio.post<dynamic>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: ''),
            statusCode: 429,
          ),
        ),
      );

      final result = await repository.pollToken('t_123');
      expect(result, isA<DeviceLinkPollRateLimited>());
    });
  });

  group('DeviceLinkController', () {
    late _MockDeviceLinkRepository deviceLinkRepo;
    late _MockAuthRepository authRepo;
    late _MockAuthController authController;
    late _MockTelegramService telegramService;
    late DeviceLinkController controller;

    setUp(() {
      deviceLinkRepo = _MockDeviceLinkRepository();
      authRepo = _MockAuthRepository();
      authController = _MockAuthController();
      telegramService = _MockTelegramService();

      controller = DeviceLinkController(
        deviceLinkRepo: deviceLinkRepo,
        authRepo: authRepo,
        authController: authController,
        telegramService: telegramService,
      );

      when(() => telegramService.openBotDeepLink(any())).thenAnswer((_) async {});
      when(() => authRepo.persistSession(any(), any())).thenAnswer((_) async {});
    });

    test('startLink success triggers bot launch and wait state', () async {
      final expires = DateTime.now().add(const Duration(minutes: 10));
      when(() => deviceLinkRepo.createToken()).thenAnswer(
        (_) async => DeviceLinkResponse(
          token: 't_123',
          deepLink: 'link',
          expiresAt: expires,
        ),
      );

      // We need to mock pollToken to not crash the timer if it ticks
      when(() => deviceLinkRepo.pollToken(any())).thenAnswer(
        (_) async => const DeviceLinkPollPending(),
      );

      await controller.startLink();

      expect(controller.state, isA<DeviceLinkWaiting>());
      final waitingState = controller.state as DeviceLinkWaiting;
      expect(waitingState.token, 't_123');
      verify(() => telegramService.openBotDeepLink('t_123')).called(1);

      controller.dispose();
    });

    test('startLink failure sets failed state', () async {
      when(() => deviceLinkRepo.createToken()).thenThrow(Exception('error'));

      await controller.startLink();

      expect(controller.state, isA<DeviceLinkFailed>());
      final failedState = controller.state as DeviceLinkFailed;
      expect(failedState.reason, DeviceLinkFailReason.network);
    });
  });
}
