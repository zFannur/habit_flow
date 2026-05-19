import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/features/ai/data/ai_messages_repository.dart';
import 'package:habit_flow/features/ai/data/chat_providers.dart';
import 'package:habit_flow/features/ai/data/openrouter_client.dart';
import 'package:habit_flow/features/ai/data/openrouter_key_repository.dart';
import 'package:habit_flow/features/ai/data/openrouter_models_repository.dart';
import 'package:habit_flow/features/habits/data/habits_providers.dart';
import 'package:habit_flow/features/journal/data/journal_providers.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _userId = '22222222-2222-2222-2222-222222222222';

class _FakeRepo extends AiMessagesRepository {
  _FakeRepo()
      : super(
          client: SupabaseClient(
            'https://example.supabase.co',
            'anon',
            httpClient: MockClient.streaming(
              (req, body) async => http.StreamedResponse(
                Stream.value(utf8.encode('[]')),
                200,
                request: req,
              ),
            ),
          ),
          userId: _userId,
        );

  final List<AiMessage> inserted = [];
  final List<AiChat> createdChats = [];
  int chatSeq = 0;
  bool failOnInsert = false;

  @override
  Future<AiChat> createChat({String? title}) async {
    chatSeq++;
    final chat = AiChat(
      id: 'chat-$chatSeq',
      userId: _userId,
      title: title ?? 'Untitled',
      createdAt: DateTime.utc(2026, 5, 7),
      updatedAt: DateTime.utc(2026, 5, 7),
    );
    createdChats.add(chat);
    return chat;
  }

  @override
  Future<List<AiMessage>> listMessages(String chatId) async {
    return inserted.where((m) => m.chatId == chatId).toList();
  }

  @override
  Future<AiMessage> insertMessage({
    required String chatId,
    required String role,
    required String content,
    int? tokensUsed,
  }) async {
    if (failOnInsert) {
      throw StateError('insert failed');
    }
    final m = AiMessage(
      id: 'msg-${inserted.length + 1}',
      chatId: chatId,
      userId: _userId,
      role: role,
      content: content,
      tokensUsed: tokensUsed,
      createdAt: DateTime.utc(2026, 5, 7, 12, inserted.length),
    );
    inserted.add(m);
    return m;
  }

  @override
  Stream<List<AiMessage>> watchMessages(String chatId) {
    return Stream.value(
      inserted.where((m) => m.chatId == chatId).toList(),
    );
  }

  @override
  Stream<List<AiChat>> watchChats() {
    return Stream.value(createdChats);
  }
}

class _FakeKeyRepo extends OpenRouterKeyRepository {
  _FakeKeyRepo({this.key = 'sk-test'});

  String? key;

  @override
  Future<String?> load() async => key;
}

class _ScriptedClient extends OpenRouterClient {
  _ScriptedClient({
    required this.chunks,
    this.error,
  }) : super(apiKey: 'sk-test');

  final List<String> chunks;
  final Object? error;

  List<OpenRouterMessage>? lastMessages;

  @override
  Stream<String> chatCompletion({
    required List<OpenRouterMessage> messages,
    String? model,
    bool stream = true,
  }) {
    lastMessages = messages;
    final controller = StreamController<String>();
    Future<void>(() async {
      for (final c in chunks) {
        controller.add(c);
      }
      if (error != null) {
        controller.addError(error!);
      }
      await controller.close();
    });
    return controller.stream;
  }
}

ProviderContainer _makeContainer({
  required _FakeRepo repo,
  required _FakeKeyRepo keyRepo,
  required OpenRouterClient client,
}) {
  final container = ProviderContainer(
    overrides: [
      currentUserIdProvider.overrideWithValue(_userId),
      aiMessagesRepositoryProvider.overrideWithValue(repo),
      openRouterKeyRepositoryProvider.overrideWithValue(keyRepo),
      openRouterKeyProvider.overrideWith((ref) async => keyRepo.key),
      // Avoid touching real habits/journal repos.
      habitsStreamProvider.overrideWith((ref) => Stream.value(const [])),
      journalEntriesProvider.overrideWith((ref) => Stream.value(const [])),
      preferredModelControllerProvider.overrideWith(
        (ref) => _NoopPreferredModel(),
      ),
      chatControllerProvider.overrideWith(
        (ref) => ChatController(
          ref: ref,
          clientFactory: (_) => client,
        ),
      ),
    ],
  );
  return container;
}

class _NoopPreferredModel
    extends StateNotifier<AsyncValue<String?>>
    implements PreferredModelController {
  _NoopPreferredModel() : super(const AsyncValue.data(null));

  @override
  Future<void> select(String modelId) async {}
}

void main() {
  group('ChatController.sendMessage', () {
    test('rejects send when no API key is stored', () async {
      final repo = _FakeRepo();
      final keyRepo = _FakeKeyRepo(key: null);
      final client = _ScriptedClient(chunks: const ['ignored']);
      final container =
          _makeContainer(repo: repo, keyRepo: keyRepo, client: client);
      addTearDown(container.dispose);

      await container.read(chatControllerProvider.notifier).sendMessage('hi');

      final state = container.read(chatControllerProvider);
      expect(state.errorMessage, 'no_key');
      expect(state.isStreaming, isFalse);
      expect(repo.inserted, isEmpty);
    });

    test('creates chat on first message and persists user + assistant',
        () async {
      final repo = _FakeRepo();
      final keyRepo = _FakeKeyRepo();
      final client = _ScriptedClient(chunks: const ['Hel', 'lo!']);
      final container =
          _makeContainer(repo: repo, keyRepo: keyRepo, client: client);
      addTearDown(container.dispose);

      await container
          .read(chatControllerProvider.notifier)
          .sendMessage('Hi there');

      // One chat created lazily, user + assistant rows persisted.
      expect(repo.createdChats, hasLength(1));
      expect(container.read(currentChatIdProvider), 'chat-1');
      expect(repo.inserted.map((m) => m.role).toList(), [
        'user',
        'assistant',
      ]);
      expect(repo.inserted.last.content, 'Hello!');

      final state = container.read(chatControllerProvider);
      expect(state.isStreaming, isFalse);
      expect(state.streamingText, isEmpty);
      expect(state.rateLimited, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('surfaces 429 as rateLimited flag', () async {
      final repo = _FakeRepo();
      final keyRepo = _FakeKeyRepo();
      final client = _ScriptedClient(
        chunks: const [],
        error: DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 429,
          ),
          type: DioExceptionType.badResponse,
        ),
      );
      final container =
          _makeContainer(repo: repo, keyRepo: keyRepo, client: client);
      addTearDown(container.dispose);

      await container
          .read(chatControllerProvider.notifier)
          .sendMessage('hi');

      final state = container.read(chatControllerProvider);
      expect(state.rateLimited, isTrue);
      expect(state.errorMessage, isNull);
      expect(state.isStreaming, isFalse);
      // User message still persisted; only the assistant reply failed.
      expect(repo.inserted.map((m) => m.role).toList(), ['user']);
    });

    test('non-429 error sets generic error message', () async {
      final repo = _FakeRepo();
      final keyRepo = _FakeKeyRepo();
      final client = _ScriptedClient(
        chunks: const [],
        error: DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 500,
          ),
          type: DioExceptionType.badResponse,
        ),
      );
      final container =
          _makeContainer(repo: repo, keyRepo: keyRepo, client: client);
      addTearDown(container.dispose);

      await container
          .read(chatControllerProvider.notifier)
          .sendMessage('hi');

      final state = container.read(chatControllerProvider);
      expect(state.rateLimited, isFalse);
      expect(state.errorMessage, 'generic');
    });

    test('reuses existing chat id on subsequent messages', () async {
      final repo = _FakeRepo();
      final keyRepo = _FakeKeyRepo();
      final client = _ScriptedClient(chunks: const ['ok']);
      final container =
          _makeContainer(repo: repo, keyRepo: keyRepo, client: client);
      addTearDown(container.dispose);

      await container.read(chatControllerProvider.notifier).sendMessage('a');
      await container.read(chatControllerProvider.notifier).sendMessage('b');

      // Only one chat row created, four messages persisted (2 turns).
      expect(repo.createdChats, hasLength(1));
      expect(repo.inserted, hasLength(4));
    });

    test('streamingText accumulates each chunk before final persist', () async {
      final repo = _FakeRepo();
      final keyRepo = _FakeKeyRepo();
      final client = _ScriptedClient(chunks: const ['Hel', 'lo,', ' world']);
      final container =
          _makeContainer(repo: repo, keyRepo: keyRepo, client: client);
      addTearDown(container.dispose);

      await container
          .read(chatControllerProvider.notifier)
          .sendMessage('hi');

      // After completion the final assistant row should hold the full text.
      expect(repo.inserted.last.content, 'Hello, world');
    });
  });
}
