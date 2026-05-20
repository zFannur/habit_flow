import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/features/ai/data/ai_messages_repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _userId = '22222222-2222-2222-2222-222222222222';
const _supabaseUrl = 'https://example.supabase.co';
const _anonKey = 'anon-test-key';

Map<String, dynamic> _chatRow({
  String id = '11111111-1111-1111-1111-111111111111',
  String title = 'Test chat',
}) =>
    {
      'id': id,
      'user_id': _userId,
      'title': title,
      'created_at': '2026-05-07T12:00:00Z',
      'updated_at': '2026-05-07T12:05:00Z',
    };

Map<String, dynamic> _messageRow({
  String id = '33333333-3333-3333-3333-333333333333',
  String chatId = '11111111-1111-1111-1111-111111111111',
  String role = 'user',
  String content = 'hi',
}) =>
    {
      'id': id,
      'chat_id': chatId,
      'user_id': _userId,
      'role': role,
      'content': content,
      'tokens_used': null,
      'created_at': '2026-05-07T12:00:00Z',
    };

class _Recorder {
  final List<http.BaseRequest> requests = [];
  final List<String> bodies = [];
}

http.Client _makeMockClient(
  _Recorder recorder,
  http.Response Function(http.BaseRequest req, String body) handler,
) {
  return MockClient.streaming((req, bodyStream) async {
    recorder.requests.add(req);
    final bodyBytes = <int>[];
    await for (final chunk in bodyStream) {
      bodyBytes.addAll(chunk);
    }
    final body = utf8.decode(bodyBytes);
    recorder.bodies.add(body);
    final res = handler(req, body);
    return http.StreamedResponse(
      Stream.value(utf8.encode(res.body)),
      res.statusCode,
      headers: res.headers,
      request: req,
    );
  });
}

AiMessagesRepository _makeRepo(http.Client httpClient) {
  final client = SupabaseClient(
    _supabaseUrl,
    _anonKey,
    httpClient: httpClient,
  );
  return AiMessagesRepository(client: client, userId: _userId);
}

void main() {
  group('AiMessage / AiChat — fromJson', () {
    test('AiMessage parses required fields', () {
      final m = AiMessage.fromJson({
        'id': 'm1',
        'chat_id': 'c1',
        'user_id': 'u1',
        'role': 'assistant',
        'content': 'hello world',
        'tokens_used': 42,
        'created_at': '2026-05-07T12:34:56Z',
      });
      expect(m.id, 'm1');
      expect(m.role, 'assistant');
      expect(m.content, 'hello world');
      expect(m.isAssistant, isTrue);
      expect(m.isUser, isFalse);
      expect(m.tokensUsed, 42);
      expect(m.createdAt.toUtc(), DateTime.utc(2026, 5, 7, 12, 34, 56));
    });

    test('AiChat parses required fields', () {
      final c = AiChat.fromJson({
        'id': 'c1',
        'user_id': 'u1',
        'title': 'My chat',
        'created_at': '2026-05-07T12:00:00Z',
        'updated_at': '2026-05-07T12:05:00Z',
      });
      expect(c.id, 'c1');
      expect(c.title, 'My chat');
    });
  });

  group('AiMessagesRepository — chats', () {
    test('listChats GETs ai_chats filtered by user, newest first', () async {
      final recorder = _Recorder();
      final httpClient = _makeMockClient(recorder, (req, _) {
        return http.Response(
          jsonEncode([_chatRow(), _chatRow(id: 'c2', title: 'Second')]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final repo = _makeRepo(httpClient);

      final chatsRes = await repo.listChats().run();
      final chats = chatsRes.match((f) => throw f, (ok) => ok);
      expect(chats, hasLength(2));

      final req = recorder.requests.single;
      expect(req.method, 'GET');
      expect(req.url.path, '/rest/v1/ai_chats');
      expect(req.url.queryParameters['user_id'], 'eq.$_userId');
      expect(req.url.queryParameters['order'], contains('updated_at.desc'));
    });

    test('createChat sends user_id and title and returns parsed row',
        () async {
      final recorder = _Recorder();
      final httpClient = _makeMockClient(recorder, (req, _) {
        return http.Response(
          jsonEncode(_chatRow(title: 'First message…')),
          201,
          headers: {'content-type': 'application/json'},
        );
      });
      final repo = _makeRepo(httpClient);

      final createdRes = await repo.createChat(title: 'First message…').run();
      final created = createdRes.match((f) => throw f, (ok) => ok);
      expect(created.title, 'First message…');

      final req = recorder.requests.single;
      expect(req.method, 'POST');
      expect(req.url.path, '/rest/v1/ai_chats');
      final body = jsonDecode(recorder.bodies.single) as Map<String, dynamic>;
      expect(body['user_id'], _userId);
      expect(body['title'], 'First message…');
    });

    test('createChat omits empty/null title', () async {
      final recorder = _Recorder();
      final httpClient = _makeMockClient(recorder, (req, _) {
        return http.Response(
          jsonEncode(_chatRow()),
          201,
          headers: {'content-type': 'application/json'},
        );
      });
      final repo = _makeRepo(httpClient);

      await repo.createChat(title: '').run();
      final body = jsonDecode(recorder.bodies.single) as Map<String, dynamic>;
      expect(body.containsKey('title'), isFalse);
    });
  });

  group('AiMessagesRepository — messages', () {
    test('listMessages filters by chat & user, ordered ascending', () async {
      final recorder = _Recorder();
      final httpClient = _makeMockClient(recorder, (req, _) {
        return http.Response(
          jsonEncode([
            _messageRow(),
            _messageRow(id: 'm2', role: 'assistant', content: 'reply'),
          ]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final repo = _makeRepo(httpClient);

      final listRes = await repo.listMessages('11111111-1111-1111-1111-111111111111').run();
      final list = listRes.match((f) => throw f, (ok) => ok);
      expect(list, hasLength(2));
      expect(list.first.role, 'user');
      expect(list.last.role, 'assistant');

      final req = recorder.requests.single;
      expect(req.method, 'GET');
      expect(req.url.path, '/rest/v1/ai_messages');
      expect(
        req.url.queryParameters['chat_id'],
        'eq.11111111-1111-1111-1111-111111111111',
      );
      expect(req.url.queryParameters['user_id'], 'eq.$_userId');
      expect(req.url.queryParameters['order'], contains('created_at.asc'));
    });

    test('insertMessage POSTs with correct payload', () async {
      final recorder = _Recorder();
      final httpClient = _makeMockClient(recorder, (req, _) {
        return http.Response(
          jsonEncode(_messageRow(role: 'assistant', content: 'hi')),
          201,
          headers: {'content-type': 'application/json'},
        );
      });
      final repo = _makeRepo(httpClient);

      final mRes = await repo.insertMessage(
        chatId: '11111111-1111-1111-1111-111111111111',
        role: 'assistant',
        content: 'hi',
      ).run();
      final m = mRes.match((f) => throw f, (ok) => ok);
      expect(m.role, 'assistant');

      final req = recorder.requests.single;
      expect(req.method, 'POST');
      expect(req.url.path, '/rest/v1/ai_messages');
      final body = jsonDecode(recorder.bodies.single) as Map<String, dynamic>;
      expect(body['chat_id'], '11111111-1111-1111-1111-111111111111');
      expect(body['user_id'], _userId);
      expect(body['role'], 'assistant');
      expect(body['content'], 'hi');
    });
  });
}
