import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/env.dart';
import '../../journal/data/journal_providers.dart';

/// Минимальное представление OpenRouter-модели, которое нужно UI настроек.
///
/// Публикуется Edge Function `models_list` в нормализованной форме:
/// `{ id, name, context_length, pricing: {prompt, completion}, free }`.
class OpenRouterModelInfo {
  const OpenRouterModelInfo({
    required this.id,
    required this.name,
    this.contextLength,
    this.promptPrice,
    this.completionPrice,
    required this.free,
  });

  final String id;
  final String name;
  final int? contextLength;
  final String? promptPrice;
  final String? completionPrice;
  final bool free;

  factory OpenRouterModelInfo.fromJson(Map<String, dynamic> json) {
    final ctx = json['context_length'];
    final pricing = json['pricing'];
    String? prompt;
    String? completion;
    if (pricing is Map) {
      prompt = pricing['prompt']?.toString();
      completion = pricing['completion']?.toString();
    }
    return OpenRouterModelInfo(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? json['id'] ?? '').toString(),
      contextLength: ctx is int
          ? ctx
          : (ctx is num ? ctx.toInt() : null),
      promptPrice: prompt,
      completionPrice: completion,
      free: json['free'] == true,
    );
  }
}

/// Репозиторий списка моделей. Читает из Edge Function `models_list`,
/// которая держит свой 24-часовой кеш и нормализует ответ OpenRouter.
class OpenRouterModelsRepository {
  OpenRouterModelsRepository({Dio? dio, String? baseUrl, String? anonKey})
      : _dio = dio ?? Dio(),
        _baseUrl = baseUrl ?? Env.supabaseUrl,
        _anonKey = anonKey ?? Env.supabaseAnonKey;

  final Dio _dio;
  final String _baseUrl;
  final String _anonKey;

  /// Текущий JWT пользователя, если он есть, иначе anon-ключ.
  String? _jwt() {
    try {
      return Supabase.instance.client.auth.currentSession?.accessToken;
    } catch (_) {
      return null;
    }
  }

  /// Запрашивает список моделей у Edge Function.
  Future<List<OpenRouterModelInfo>> list() async {
    final token = _jwt() ?? _anonKey;
    final response = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/functions/v1/models_list',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'apikey': _anonKey,
          'Content-Type': 'application/json',
        },
      ),
    );
    final data = response.data?['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((m) => OpenRouterModelInfo.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }
}

/// Singleton-репозиторий моделей.
final openRouterModelsRepositoryProvider =
    Provider<OpenRouterModelsRepository>(
  (_) => OpenRouterModelsRepository(),
);

/// Список моделей OpenRouter, отдаваемый Edge Function (с 24h-кешем сервера).
final availableModelsProvider = FutureProvider<List<OpenRouterModelInfo>>(
  (ref) => ref.watch(openRouterModelsRepositoryProvider).list(),
);

/// Контроллер сохранения выбранной модели в `users.ai_model`.
class PreferredModelController extends StateNotifier<AsyncValue<String?>> {
  PreferredModelController(this._client, this._userId)
      : super(const AsyncValue.loading()) {
    _bootstrap();
  }

  final SupabaseClient _client;
  final String _userId;

  Future<void> _bootstrap() async {
    try {
      final row = await _client
          .from('users')
          .select('ai_model')
          .eq('id', _userId)
          .maybeSingle();
      final value = row?['ai_model']?.toString();
      state = AsyncValue.data(value);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Сохранить выбор пользователя в БД. Оптимистично обновляет state.
  Future<void> select(String modelId) async {
    state = AsyncValue.data(modelId);
    try {
      await _client
          .from('users')
          .update({'ai_model': modelId})
          .eq('id', _userId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Текущая выбранная модель пользователя (`users.ai_model`).
final preferredModelControllerProvider = StateNotifierProvider<
    PreferredModelController, AsyncValue<String?>>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final userId = ref.watch(currentUserIdProvider);
  return PreferredModelController(client, userId);
});
