import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/telegram_service.dart';
import '../data/auth_providers.dart';
import '../data/auth_repository.dart';
import '../data/device_link_repository.dart';
import '../domain/auth_state.dart';
import '../domain/device_link_state.dart';

final deviceLinkRepositoryProvider = Provider<DeviceLinkRepository>((ref) {
  return DeviceLinkRepository();
});

final deviceLinkControllerProvider =
    StateNotifierProvider<DeviceLinkController, DeviceLinkState>((ref) {
  return DeviceLinkController(
    deviceLinkRepo: ref.watch(deviceLinkRepositoryProvider),
    authRepo: ref.watch(authRepositoryProvider),
    authController: ref.watch(authStateProvider.notifier),
    telegramService: ref.watch(telegramServiceProvider),
  );
});

class DeviceLinkController extends StateNotifier<DeviceLinkState> {
  DeviceLinkController({
    required this.deviceLinkRepo,
    required this.authRepo,
    required this.authController,
    required this.telegramService,
  }) : super(const DeviceLinkIdle());

  final DeviceLinkRepository deviceLinkRepo;
  final AuthRepository authRepo;
  final AuthController authController;
  final TelegramService telegramService;

  Timer? _pollTimer;
  int _consecutiveErrors = 0;
  static const int _maxConsecutiveErrors = 5;

  /// Start the device link flow: create a token, launch Telegram, and poll.
  Future<void> startLink() async {
    if (state is DeviceLinkOpening || state is DeviceLinkWaiting) {
      return;
    }

    state = const DeviceLinkOpening();
    _consecutiveErrors = 0;

    try {
      final response = await deviceLinkRepo.createToken();
      
      state = DeviceLinkWaiting(
        token: response.token,
        deepLink: response.deepLink,
        expiresAt: response.expiresAt,
      );

      // Launch Telegram bot deep link
      await telegramService.openBotDeepLink(response.token);

      // Start polling
      _startPolling(response.token, response.expiresAt);
    } catch (_) {
      state = const DeviceLinkFailed(DeviceLinkFailReason.network);
    }
  }

  /// Cancel any active linking flow and reset to idle.
  void cancelLink() {
    _stopPolling();
    state = const DeviceLinkIdle();
  }

  void _startPolling(String token, DateTime expiresAt) {
    _stopPolling();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final now = DateTime.now().toUtc();
      if (now.isAfter(expiresAt.toUtc())) {
        _stopPolling();
        state = const DeviceLinkFailed(DeviceLinkFailReason.expired);
        return;
      }

      try {
        final pollRes = await deviceLinkRepo.pollToken(token);
        _consecutiveErrors = 0; // reset on successful request

        if (pollRes is DeviceLinkPollPending) {
          // Keep waiting
          return;
        } else if (pollRes is DeviceLinkPollSuccess) {
          _stopPolling();
          state = const DeviceLinkSuccess();
          // Persist the session locally and update active auth state
          await authRepo.persistSession(pollRes.jwt, pollRes.user);
          authController.state = Authenticated(jwt: pollRes.jwt, user: pollRes.user);
        } else if (pollRes is DeviceLinkPollExpired) {
          _stopPolling();
          state = const DeviceLinkFailed(DeviceLinkFailReason.expired);
        } else if (pollRes is DeviceLinkPollConsumed) {
          _stopPolling();
          state = const DeviceLinkFailed(DeviceLinkFailReason.consumed);
        } else if (pollRes is DeviceLinkPollRateLimited) {
          // Just skip this tick, wait for the next periodic check
          return;
        }
      } catch (_) {
        _consecutiveErrors++;
        if (_consecutiveErrors >= _maxConsecutiveErrors) {
          _stopPolling();
          state = const DeviceLinkFailed(DeviceLinkFailReason.network);
        }
      }
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }
}
