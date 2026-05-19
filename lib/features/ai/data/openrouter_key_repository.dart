import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/config/env.dart';
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
  Future<void> save(String key) async {
    await _storage.write(key: _kStorageKey, value: key);
  }

  /// Прочитать сохранённый ключ. `null`, если не задан.
  Future<String?> load() async {
    return _storage.read(key: _kStorageKey);
  }

  /// Удалить ключ.
  Future<void> clear() async {
    await _storage.delete(key: _kStorageKey);
  }

  /// Проверить ключ через `GET /models`. 200 — валиден, иначе — нет.
  ///
  /// Если [key] не передан, используем сохранённый. Если ничего не сохранено —
  /// возвращаем `false`.
  Future<bool> isValid({String? key}) async {
    final effective = key ?? await load();
    if (effective == null || effective.isEmpty) return false;
    try {
      final response = await _dio.get<dynamic>(
        '${Env.openRouterBaseUrl}/models',
        options: Options(
          headers: {'Authorization': 'Bearer $effective'},
          // Не позволяем dio бросать на 4xx — нам нужен сам код.
          validateStatus: (_) => true,
        ),
      );
      return response.statusCode == 200;
    } on DioException {
      return false;
    } catch (_) {
      return false;
    }
  }
}

/// Singleton-провайдер хранилища ключа.
final openRouterKeyRepositoryProvider = Provider<OpenRouterKeyRepository>(
  (ref) => OpenRouterKeyRepository(),
);

/// Текущий ключ (из secure-storage). `null`, если ничего не сохранено.
final openRouterKeyProvider = FutureProvider<String?>((ref) async {
  return ref.read(openRouterKeyRepositoryProvider).load();
});

/// Состояние проверки ключа в settings.
enum OpenRouterKeyStatus { unchecked, checking, ok, error }

/// Notifier для UI ai_settings_screen — хранит текущий ключ и статус проверки.
class OpenRouterKeyController
    extends StateNotifier<OpenRouterKeyControllerState> {
  OpenRouterKeyController(this._repo)
    : super(const OpenRouterKeyControllerState());

  final OpenRouterKeyRepository _repo;

  Future<void> bootstrap() async {
    final stored = await _repo.load();
    state = state.copyWith(key: stored);
  }

  Future<void> save(String key) async {
    await _repo.save(key);
    state = state.copyWith(
      key: key,
      status: OpenRouterKeyStatus.unchecked,
    );
  }

  Future<void> clear() async {
    await _repo.clear();
    state = const OpenRouterKeyControllerState();
  }

  Future<void> test() async {
    final current = state.key;
    if (current == null || current.isEmpty) {
      state = state.copyWith(status: OpenRouterKeyStatus.error);
      return;
    }
    state = state.copyWith(status: OpenRouterKeyStatus.checking);
    final ok = await _repo.isValid(key: current);
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
      final controller = OpenRouterKeyController(repo);
      // Загружаем сохранённый ключ при первом обращении.
      controller.bootstrap();
      return controller;
    });
