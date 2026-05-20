import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/features/journal/data/journal_entry_model.dart';
import 'package:habit_flow/features/journal/data/journal_repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _userId = '22222222-2222-2222-2222-222222222222';
const _supabaseUrl = 'https://example.supabase.co';
const _anonKey = 'anon-test-key';

Map<String, dynamic> _row({
  String id = '11111111-1111-1111-1111-111111111111',
  String entryDate = '2026-05-07',
}) =>
    {
      'id': id,
      'user_id': _userId,
      'entry_date': entryDate,
      'free_text': 'hi',
      'mood': 7,
      'energy': 6,
      'answers': {'q1': 'A'},
      'created_at': '2026-05-07T12:00:00Z',
      'updated_at': '2026-05-07T12:05:00Z',
    };

/// Records each request the repo issues so we can assert on URL / body / verb.
class _Recorder {
  final List<http.BaseRequest> requests = [];
}

http.Client _makeMockClient(
  _Recorder recorder,
  http.Response Function(http.BaseRequest req) handler,
) {
  return MockClient.streaming((req, body) async {
    recorder.requests.add(req);
    final res = handler(req);
    return http.StreamedResponse(
      Stream.value(utf8.encode(res.body)),
      res.statusCode,
      headers: res.headers,
      request: req,
    );
  });
}

JournalRepository _makeRepo(http.Client httpClient) {
  final client = SupabaseClient(
    _supabaseUrl,
    _anonKey,
    httpClient: httpClient,
  );
  return JournalRepository(client: client, userId: _userId);
}

void main() {
  group('JournalRepository', () {
    test('findByDate returns parsed model when row exists', () async {
      final recorder = _Recorder();
      final httpClient = _makeMockClient(recorder, (req) {
        return http.Response(
          jsonEncode(_row()),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final repo = _makeRepo(httpClient);

      final entryRes = await repo.findByDate(DateTime.utc(2026, 5, 7)).run();
      final entry = entryRes.getOrElse((f) => fail('findByDate failed: $f'));
      expect(entry, isNotNull);
      expect(entry!.id, '11111111-1111-1111-1111-111111111111');
      expect(entry.date, DateTime.utc(2026, 5, 7));
      expect(entry.text, 'hi');

      final req = recorder.requests.single;
      expect(req.method, 'GET');
      expect(req.url.path, '/rest/v1/journal_entries');
      expect(req.url.queryParameters['user_id'], 'eq.$_userId');
      expect(req.url.queryParameters['entry_date'], 'eq.2026-05-07');
    });

    test('findByDate returns null when no row', () async {
      final recorder = _Recorder();
      final httpClient = _makeMockClient(recorder, (req) {
        // PostgREST returns empty body / null for maybeSingle when no rows.
        return http.Response(
          'null',
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final repo = _makeRepo(httpClient);

      final entryRes = await repo.findByDate(DateTime.utc(2026, 5, 7)).run();
      final entry = entryRes.getOrElse((f) => fail('findByDate failed: $f'));
      expect(entry, isNull);
    });

    test('upsert sends payload and returns parsed row', () async {
      final recorder = _Recorder();
      final httpClient = _makeMockClient(recorder, (req) {
        return http.Response(
          jsonEncode(_row()),
          201,
          headers: {'content-type': 'application/json'},
        );
      });
      final repo = _makeRepo(httpClient);

      final entry = JournalEntryModel(
        id: '11111111-1111-1111-1111-111111111111',
        userId: _userId,
        date: DateTime.utc(2026, 5, 7),
        text: 'hi',
        mood: 7,
        energy: 6,
        answers: const {'q1': 'A'},
        createdAt: DateTime.utc(2026, 5, 7, 12),
        updatedAt: DateTime.utc(2026, 5, 7, 12, 5),
      );

      final resultRes = await repo.upsert(entry).run();
      final result = resultRes.getOrElse((f) => fail('upsert failed: $f'));
      expect(result.id, entry.id);

      final req = recorder.requests.single as http.Request;
      expect(req.method, 'POST');
      expect(req.url.path, '/rest/v1/journal_entries');
      // upsert is signalled via Prefer header.
      expect(req.headers['Prefer'], contains('resolution=merge-duplicates'));

      final body = jsonDecode(req.body) as Map<String, dynamic>;
      expect(body['entry_date'], '2026-05-07');
      expect(body['user_id'], _userId);
      expect(body['free_text'], 'hi');
      expect(body.containsKey('linked_habit_log_ids'), isFalse);
      expect(body.containsKey('created_at'), isFalse);
    });

    test('delete issues DELETE filtered by id and user', () async {
      final recorder = _Recorder();
      final httpClient = _makeMockClient(recorder, (req) {
        return http.Response('', 204);
      });
      final repo = _makeRepo(httpClient);

      final result = await repo.delete('abc').run();
      expect(result.isRight(), isTrue);

      final req = recorder.requests.single;
      expect(req.method, 'DELETE');
      expect(req.url.path, '/rest/v1/journal_entries');
      expect(req.url.queryParameters['id'], 'eq.abc');
      expect(req.url.queryParameters['user_id'], 'eq.$_userId');
    });

    test('totalCount asks for exact count and returns int', () async {
      final recorder = _Recorder();
      final httpClient = _makeMockClient(recorder, (req) {
        return http.Response(
          '[]',
          200,
          headers: {
            'content-type': 'application/json',
            'content-range': '0-0/42',
          },
        );
      });
      final repo = _makeRepo(httpClient);

      final nRes = await repo.totalCount().run();
      final n = nRes.getOrElse((f) => fail('totalCount failed: $f'));
      expect(n, 42);

      final req = recorder.requests.single;
      // count() uses HEAD with Prefer: count=exact.
      expect(req.method, anyOf('HEAD', 'GET'));
      expect(req.headers['Prefer'], contains('count=exact'));
      expect(req.url.queryParameters['user_id'], 'eq.$_userId');
    });
  });
}
