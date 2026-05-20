import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../core/config/env.dart';
import '../../../core/errors/failure.dart';
import '../../../core/errors/result.dart';

/// Описание модели OpenRouter из `GET /models`.
///
/// Только нужные нам поля — остальное игнорируем, чтобы не падать на
/// расширении API.
class OpenRouterModel {
  const OpenRouterModel({
    required this.id,
    required this.name,
    this.contextLength,
    this.promptPrice,
    this.completionPrice,
  });

  final String id;
  final String name;
  final int? contextLength;
  final String? promptPrice;
  final String? completionPrice;

  factory OpenRouterModel.fromJson(Map<String, dynamic> json) {
    final pricing = json['pricing'];
    String? prompt;
    String? completion;
    if (pricing is Map) {
      prompt = pricing['prompt']?.toString();
      completion = pricing['completion']?.toString();
    }
    final ctx = json['context_length'];
    return OpenRouterModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? json['id'] ?? '').toString(),
      contextLength: ctx is int ? ctx : (ctx is num ? ctx.toInt() : null),
      promptPrice: prompt,
      completionPrice: completion,
    );
  }
}

/// Сообщение для chat completion endpoint OpenRouter.
class OpenRouterMessage {
  const OpenRouterMessage({required this.role, required this.content});

  final String role;
  final String content;

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

/// Тонкая обёртка над OpenRouter HTTP API.
///
/// Ключ принимается через конструктор и **не** хранится в самом клиенте
/// дольше, чем сам инстанс. Для inject-а в тестах можно передать свой [Dio].
class OpenRouterClient {
  OpenRouterClient({
    required this.apiKey,
    Dio? dio,
    String? baseUrl,
  }) : _dio = dio ?? Dio(),
       _baseUrl = baseUrl ?? Env.openRouterBaseUrl;

  final String apiKey;
  final Dio _dio;
  final String _baseUrl;

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
    // OpenRouter рекомендует эти заголовки для атрибуции / лимитов.
    'HTTP-Referer': 'https://habitflow.app',
    'X-Title': 'HabitFlow',
  };

  /// Список доступных моделей. Бросает [DioException] на не-2xx.
  AppTask<List<OpenRouterModel>> models() {
    return TaskEither.tryCatch(
      () async {
        final response = await _dio.get<Map<String, dynamic>>(
          '$_baseUrl/models',
          options: Options(headers: _headers),
        );
        final data = response.data?['data'];
        if (data is! List) return const [];
        return data
            .whereType<Map>()
            .map((m) => OpenRouterModel.fromJson(Map<String, dynamic>.from(m)))
            .toList();
      },
      (e, st) => Failure.unknown(message: e.toString()),
    );
  }

  /// Chat completion. Возвращает [Stream<String>] с дельтами.
  ///
  /// При [stream] = false вернётся стрим с одним элементом — полным ответом.
  /// При [stream] = true парсятся SSE-чанки `data: {...}`.
  Stream<String> chatCompletion({
    required List<OpenRouterMessage> messages,
    String? model,
    bool stream = true,
  }) {
    final controller = StreamController<String>();

    final body = <String, dynamic>{
      'model': model ?? Env.defaultModel,
      'messages': messages.map((m) => m.toJson()).toList(),
      'stream': stream,
    };

    Future<void> run() async {
      try {
        if (!stream) {
          final response = await _dio.post<Map<String, dynamic>>(
            '$_baseUrl/chat/completions',
            data: jsonEncode(body),
            options: Options(headers: _headers),
          );
          final choices = response.data?['choices'];
          if (choices is List && choices.isNotEmpty) {
            final msg = choices.first is Map
                ? (choices.first as Map)['message']
                : null;
            final content = msg is Map ? msg['content']?.toString() : null;
            if (content != null && content.isNotEmpty) {
              controller.add(content);
            }
          }
          await controller.close();
          return;
        }

        final response = await _dio.post<ResponseBody>(
          '$_baseUrl/chat/completions',
          data: jsonEncode(body),
          options: Options(
            headers: {..._headers, 'Accept': 'text/event-stream'},
            responseType: ResponseType.stream,
          ),
        );

        final body0 = response.data;
        if (body0 == null) {
          await controller.close();
          return;
        }

        // Собираем буфер построчно: SSE-сообщения разделены `\n\n`,
        // внутри одного сообщения строка с полезной нагрузкой начинается
        // с `data: `.
        var buffer = '';
        await for (final chunk in body0.stream) {
          buffer += utf8.decode(chunk, allowMalformed: true);
          while (true) {
            final sepIndex = buffer.indexOf('\n\n');
            if (sepIndex == -1) break;
            final event = buffer.substring(0, sepIndex);
            buffer = buffer.substring(sepIndex + 2);
            for (final line in event.split('\n')) {
              if (!line.startsWith('data:')) continue;
              final payload = line.substring(5).trim();
              if (payload.isEmpty || payload == '[DONE]') continue;
              try {
                final json = jsonDecode(payload);
                if (json is Map) {
                  final choices = json['choices'];
                  if (choices is List && choices.isNotEmpty) {
                    final delta = choices.first is Map
                        ? (choices.first as Map)['delta']
                        : null;
                    final content = delta is Map
                        ? delta['content']?.toString()
                        : null;
                    if (content != null && content.isNotEmpty) {
                      controller.add(content);
                    }
                  }
                }
              } catch (_) {
                // Игнорируем битые чанки — стриминг должен продолжаться.
              }
            }
          }
        }
        await controller.close();
      } catch (e, st) {
        controller.addError(e, st);
        await controller.close();
      }
    }

    unawaited(run());
    return controller.stream;
  }
}
