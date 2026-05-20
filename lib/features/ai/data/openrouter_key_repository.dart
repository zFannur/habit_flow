import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';

import '../../../core/config/env.dart';
import '../../../core/errors/failure.dart';
import '../../../core/errors/result.dart';
import 'openrouter_client.dart';

/// Ключ в secure-storage для OpenRouter API key.
const _kStorageKey = 'openrouter_key';

/// Хранилище OpenRouter API key пользователя (BYO).
///
/// Используем [FlutterSecureStorage] — на Web он реализован поверх WebCrypto,
/// на нативных платформах — поверх Keychain / Keystore.
class OpenRouterKeyRepository {
  OpenRouterKeyRepository({FlutterSecureStorage? storage, Dio? dio})
    : _storage = storage ?? const FlutterSecureStorage(),
      _dio = dio ?? Dio();

  final FlutterSecureStorage _storage;
  final Dio _dio;

  /// Сохранить ключ.
  AppTask<void> save(String key) {
    return TaskEither.tryCatch(
      () => _storage.write(key: _kStorageKey, value: key),
      (e, st) => Failure.unknown(message: e.toString()),
    );
  }

  /// Прочитать сохранённый ключ. `null`, если не задан.
  AppTask<String?> load() {
    return TaskEither.tryCatch(
      () => _storage.read(key: _kStorageKey),
      (e, st) => Failure.unknown(message: e.toString()),
    );
  }

  /// Удалить ключ.
  AppTask<void> clear() {
    return TaskEither.tryCatch(
      () => _storage.delete(key: _kStorageKey),
      (e, st) => Failure.unknown(message: e.toString()),
    );
  }

  /// Проверить ключ через `GET /models`. 200 — валиден, иначе — нет.
  ///
  /// Если [key] не передан, используем сохранённый. Если ничего не сохранено —
  /// возвращаем `false`.
  AppTask<bool> isValid({String? key}) {
    return TaskEither.tryCatch(
      () async {
        final loadRes = await load().run();
        final effective = key ?? loadRes.getOrElse((_) => null);
        if (effective == null || effective.isEmpty) return false;
        final response = await _dio.get<dynamic>(
          '${Env.openRouterBaseUrl}/models',
          options: Options(
            headers: {'Authorization': 'Bearer $effective'},
            // Не позволяем dio бросать на 4xx — нам нужен сам код.
            validateStatus: (_) => true,
          ),
        );
        return response.statusCode == 200;
      },
      (e, st) => Failure.unknown(message: e.toString()),
    );
  }
}

/// Singleton-провайдер хранилища ключа.
final openRouterKeyRepositoryProvider = Provider<OpenRouterKeyRepository>(
  (ref) => OpenRouterKeyRepository(),
);

/// Текущий ключ (из secure-storage). `null`, если ничего не сохранено.
final openRouterKeyProvider = FutureProvider<String?>((ref) async {
  final res = await ref.read(openRouterKeyRepositoryProvider).load().run();
  return res.getOrElse((_) => null);
});

/// Состояние проверки ключа в settings.
enum OpenRouterKeyStatus { unchecked, checking, ok, error }

/// Notifier для UI ai_settings_screen — хранит текущий ключ и статус проверки.
class OpenRouterKeyController
    extends StateNotifier<OpenRouterKeyControllerState> {
  OpenRouterKeyController(this._repo, this._ref)
    : super(const OpenRouterKeyControllerState());

  final OpenRouterKeyRepository _repo;
  final Ref _ref;

  Future<void> bootstrap() async {
    final storedRes = await _repo.load().run();
    final stored = storedRes.getOrElse((_) => null);
    state = state.copyWith(key: stored);
  }

  Future<void> save(String key) async {
    await _repo.save(key).run();
    state = state.copyWith(
      key: key,
      status: OpenRouterKeyStatus.unchecked,
    );
    _ref.invalidate(openRouterKeyProvider);
  }

  Future<void> clear() async {
    await _repo.clear().run();
    state = const OpenRouterKeyControllerState();
    _ref.invalidate(openRouterKeyProvider);
  }

  Future<void> test() async {
    final current = state.key;
    if (current == null || current.isEmpty) {
      state = state.copyWith(status: OpenRouterKeyStatus.error);
      return;
    }
    state = state.copyWith(status: OpenRouterKeyStatus.checking);
    final okRes = await _repo.isValid(key: current).run();
    final ok = okRes.getOrElse((_) => false);
    state = state.copyWith(
      status: ok ? OpenRouterKeyStatus.ok : OpenRouterKeyStatus.error,
    );
  }

  /// Создаёт OpenRouterClient с текущим ключом, если он есть.
  OpenRouterClient? buildClient() {
    final k = state.key;
    if (k == null || k.isEmpty) return null;
    return OpenRouterClient(apiKey: k);
  }
}

class OpenRouterKeyControllerState {
  const OpenRouterKeyControllerState({
    this.key,
    this.status = OpenRouterKeyStatus.unchecked,
  });

  final String? key;
  final OpenRouterKeyStatus status;

  bool get hasKey => key != null && key!.isNotEmpty;

  OpenRouterKeyControllerState copyWith({
    String? key,
    OpenRouterKeyStatus? status,
  }) {
    return OpenRouterKeyControllerState(
      key: key ?? this.key,
      status: status ?? this.status,
    );
  }
}

final openRouterKeyControllerProvider =
    StateNotifierProvider<
      OpenRouterKeyController,
      OpenRouterKeyControllerState
    >((ref) {
      final repo = ref.watch(openRouterKeyRepositoryProvider);
      final controller = OpenRouterKeyController(repo, ref);
      // Загружаем сохранённый ключ при первом обращении.
      controller.bootstrap();
      return controller;
    });
