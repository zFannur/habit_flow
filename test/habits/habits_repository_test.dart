import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/core/error/repository_error.dart';
import 'package:habit_flow/features/habits/data/habit_log_model.dart';
import 'package:habit_flow/features/habits/data/habit_logs_repository.dart';
import 'package:habit_flow/features/habits/data/habit_model.dart';
import 'package:habit_flow/features/habits/data/habits_repository.dart';
import 'package:habit_flow/features/habits/domain/habit_log_status.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _userId = '22222222-2222-2222-2222-222222222222';
const _habitId = '11111111-1111-1111-1111-111111111111';
const _supabaseUrl = 'https://example.supabase.co';
const _anonKey = 'anon-test-key';

Map<String, dynamic> _habitRow({
  String id = _habitId,
  String habitType = 'binary',
  String scheduleType = 'daily',
  Map<String, dynamic> scheduleConfig = const <String, dynamic>{},
  String startDate = '2026-01-01',
  bool isArchived = false,
}) =>
    {
      'id': id,
      'user_id': _userId,
      'name': 'Drink water',
      'category': null,
      'category_id': null,
      'habit_type': habitType,
      'icon_emoji': '💧',
      'icon_telegram_file_id': null,
      'color': '#3B82F6',
      'target_value': null,
      'target_unit': null,
      'schedule_type': scheduleType,
      'schedule_config': scheduleConfig,
      'reminder_times': <String>[],
      'start_date': startDate,
      'end_date': null,
      'stack_after_habit_id': null,
      'implementation_when': null,
      'implementation_where': null,
      'identity_statement': null,
      'two_minute_version': null,
      'reward': null,
      'is_archived': isArchived,
      'position': 0,
      'created_at': '2026-01-01T08:00:00.000Z',
      'updated_at': '2026-01-02T09:30:00.000Z',
    };

Map<String, dynamic> _logRow({
  String id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  String date = '2026-05-07',
  String status = 'done',
}) =>
    {
      'id': id,
      'user_id': _userId,
      'habit_id': _habitId,
      'log_date': date,
      'status': status,
      'value': null,
      'comment': null,
      'created_at': '2026-05-07T20:15:00.000Z',
    };

class _Recorder {
  final List<http.BaseRequest> requests = [];
  final List<String> bodies = [];
}

http.Client _makeMockClient(
  _Recorder recorder,
  http.Response Function(http.BaseRequest req, String? body) handler,
) {
  return MockClient.streaming((req, bodyStream) async {
    recorder.requests.add(req);
    String? bodyText;
    if (req is http.Request) {
      bodyText = req.body;
    } else {
      bodyText = null;
    }
    if (bodyText != null) recorder.bodies.add(bodyText);
    final res = handler(req, bodyText);
    return http.StreamedResponse(
      Stream.value(utf8.encode(res.body)),
      res.statusCode,
      headers: res.headers,
      request: req,
    );
  });
}

SupabaseClient _makeSb(http.Client httpClient) {
  return SupabaseClient(
    _supabaseUrl,
    _anonKey,
    httpClient: httpClient,
  );
}

HabitsRepository _makeRepo(http.Client httpClient) {
  return HabitsRepository(client: _makeSb(httpClient), userId: _userId);
}

HabitLogsRepository _makeLogsRepo(http.Client httpClient) {
  return HabitLogsRepository(client: _makeSb(httpClient), userId: _userId);
}

HabitModel _modelFrom(Map<String, dynamic> row) => HabitModel.fromJson(row);

void main() {
  group('HabitsRepository', () {
    test('listForToday filters by isToday for daily', () async {
      final recorder = _Recorder();
      final httpClient = _makeMockClient(recorder, (req, body) {
        return http.Response(
          jsonEncode([_habitRow()]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final repo = _makeRepo(httpClient);

      final list = await repo.listForToday(DateTime(2026, 5, 7));
      expect(list, hasLength(1));
      expect(list.single.id, _habitId);

      final req = recorder.requests.single;
      expect(req.method, 'GET');
      expect(req.url.path, '/rest/v1/habits');
      expect(req.url.queryParameters['user_id'], 'eq.$_userId');
      expect(req.url.queryParameters['is_archived'], 'eq.false');
    });

    test('listForToday excludes habits not scheduled for the day', () async {
      final recorder = _Recorder();
      // Weekdays habit Mon-Fri only.
      final habit = _habitRow(
        scheduleType: 'weekdays',
        scheduleConfig: {'weekdays': [1, 2, 3, 4, 5]},
      );
      final httpClient = _makeMockClient(recorder, (req, body) {
        return http.Response(
          jsonEncode([habit]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final repo = _makeRepo(httpClient);

      // 2026-05-09 is Saturday — should be filtered out.
      final list = await repo.listForToday(DateTime(2026, 5, 9));
      expect(list, isEmpty);
    });

    test('listForToday respects every_n_days cadence', () async {
      final recorder = _Recorder();
      final habit = _habitRow(
        scheduleType: 'every_n_days',
        scheduleConfig: {'every_n': 3},
        startDate: '2026-01-01',
      );
      final httpClient = _makeMockClient(recorder, (req, body) {
        return http.Response(
          jsonEncode([habit]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final repo = _makeRepo(httpClient);

      // 2026-01-04 is exactly 3 days after start.
      final hit = await repo.listForToday(DateTime(2026, 1, 4));
      expect(hit, hasLength(1));

      // 2026-01-02 is 1 day after start — not divisible by 3.
      final miss = await repo.listForToday(DateTime(2026, 1, 2));
      expect(miss, isEmpty);
    });

    test('listForToday respects monthly_dates cadence', () async {
      final recorder = _Recorder();
      final habit = _habitRow(
        scheduleType: 'monthly_dates',
        scheduleConfig: {'dates': [1, 15]},
      );
      final httpClient = _makeMockClient(recorder, (req, body) {
        return http.Response(
          jsonEncode([habit]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final repo = _makeRepo(httpClient);

      expect(await repo.listForToday(DateTime(2026, 5, 1)), hasLength(1));
      expect(await repo.listForToday(DateTime(2026, 5, 7)), isEmpty);
    });

    test('listForToday n_per_week always returns the habit on any date',
        () async {
      final recorder = _Recorder();
      final habit = _habitRow(
        scheduleType: 'n_per_week',
        scheduleConfig: {'n': 3},
      );
      final httpClient = _makeMockClient(recorder, (req, body) {
        return http.Response(
          jsonEncode([habit]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final repo = _makeRepo(httpClient);

      expect(await repo.listForToday(DateTime(2026, 5, 7)), hasLength(1));
      expect(await repo.listForToday(DateTime(2026, 5, 9)), hasLength(1));
    });

    test('create posts payload and returns parsed model', () async {
      final recorder = _Recorder();
      final httpClient = _makeMockClient(recorder, (req, body) {
        return http.Response(
          jsonEncode(_habitRow()),
          201,
          headers: {'content-type': 'application/json'},
        );
      });
      final repo = _makeRepo(httpClient);

      final input = _modelFrom(_habitRow());
      final out = await repo.create(input);
      expect(out.id, _habitId);

      final req = recorder.requests.single as http.Request;
      expect(req.method, 'POST');
      expect(req.url.path, '/rest/v1/habits');
      final payload = jsonDecode(req.body) as Map<String, dynamic>;
      expect(payload['user_id'], _userId);
      expect(payload.containsKey('created_at'), isFalse);
      expect(payload.containsKey('updated_at'), isFalse);
    });

    test('update issues PATCH filtered by id and user', () async {
      final recorder = _Recorder();
      final httpClient = _makeMockClient(recorder, (req, body) {
        return http.Response(
          jsonEncode(_habitRow()),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final repo = _makeRepo(httpClient);

      final input = _modelFrom(_habitRow());
      await repo.update(input);

      final req = recorder.requests.single;
      expect(req.method, 'PATCH');
      expect(req.url.queryParameters['id'], 'eq.$_habitId');
      expect(req.url.queryParameters['user_id'], 'eq.$_userId');
    });

    test('archive sets is_archived=true via PATCH', () async {
      final recorder = _Recorder();
      final httpClient = _makeMockClient(recorder, (req, body) {
        return http.Response('', 204);
      });
      final repo = _makeRepo(httpClient);

      await repo.archive(_habitId);

      final req = recorder.requests.single as http.Request;
      expect(req.method, 'PATCH');
      expect(req.url.queryParameters['id'], 'eq.$_habitId');
      final body = jsonDecode(req.body) as Map<String, dynamic>;
      expect(body['is_archived'], true);
    });

    test('delete issues DELETE filtered by id and user', () async {
      final recorder = _Recorder();
      final httpClient = _makeMockClient(recorder, (req, body) {
        return http.Response('', 204);
      });
      final repo = _makeRepo(httpClient);

      await repo.delete(_habitId);

      final req = recorder.requests.single;
      expect(req.method, 'DELETE');
      expect(req.url.queryParameters['id'], 'eq.$_habitId');
      expect(req.url.queryParameters['user_id'], 'eq.$_userId');
    });

    test('error from PostgREST is wrapped in RepositoryError', () async {
      final recorder = _Recorder();
      final httpClient = _makeMockClient(recorder, (req, body) {
        return http.Response(
          jsonEncode({
            'message': 'denied',
            'code': '401',
          }),
          401,
          headers: {'content-type': 'application/json'},
        );
      });
      final repo = _makeRepo(httpClient);

      Object? caught;
      try {
        await repo.listForToday(DateTime(2026, 5, 7));
      } catch (e) {
        caught = e;
      }
      expect(caught, isA<RepositoryError>());
    });

    test('watchAll for a foreign user errors immediately', () async {
      final recorder = _Recorder();
      final httpClient = _makeMockClient(recorder, (req, body) {
        return http.Response('[]', 200);
      });
      final repo = _makeRepo(httpClient);

      final stream = repo.watchAll('other-user');
      Object? caught;
      try {
        await stream.first;
      } catch (e) {
        caught = e;
      }
      expect(caught, isA<RepositoryUnauthorizedError>());
    });
  });

  group('HabitLogsRepository', () {
    test('log upserts and returns parsed row', () async {
      final recorder = _Recorder();
      final httpClient = _makeMockClient(recorder, (req, body) {
        return http.Response(
          jsonEncode(_logRow()),
          201,
          headers: {'content-type': 'application/json'},
        );
      });
      final repo = _makeLogsRepo(httpClient);

      final out = await repo.log(
        _habitId,
        DateTime(2026, 5, 7),
        HabitLogStatus.done,
        value: 1,
        comment: 'ok',
      );
      expect(out, isA<HabitLogModel>());
      expect(out.status, HabitLogStatus.done);

      final req = recorder.requests.single as http.Request;
      expect(req.method, 'POST');
      expect(req.url.path, '/rest/v1/habit_logs');
      expect(req.headers['Prefer'], contains('resolution=merge-duplicates'));
      final payload = jsonDecode(req.body) as Map<String, dynamic>;
      expect(payload['user_id'], _userId);
      expect(payload['habit_id'], _habitId);
      expect(payload['log_date'], '2026-05-07');
      expect(payload['status'], 'done');
      expect(payload['value'], 1);
      expect(payload['comment'], 'ok');
    });

    test('log omits null value and comment from payload', () async {
      final recorder = _Recorder();
      final httpClient = _makeMockClient(recorder, (req, body) {
        return http.Response(
          jsonEncode(_logRow()),
          201,
          headers: {'content-type': 'application/json'},
        );
      });
      final repo = _makeLogsRepo(httpClient);

      await repo.log(
        _habitId,
        DateTime(2026, 5, 7),
        HabitLogStatus.skipped,
      );

      final req = recorder.requests.single as http.Request;
      final payload = jsonDecode(req.body) as Map<String, dynamic>;
      expect(payload.containsKey('value'), isFalse);
      expect(payload.containsKey('comment'), isFalse);
    });

    test('undo issues DELETE filtered by id and user', () async {
      final recorder = _Recorder();
      final httpClient = _makeMockClient(recorder, (req, body) {
        return http.Response('', 204);
      });
      final repo = _makeLogsRepo(httpClient);

      await repo.undo('log-1');

      final req = recorder.requests.single;
      expect(req.method, 'DELETE');
      expect(req.url.queryParameters['id'], 'eq.log-1');
      expect(req.url.queryParameters['user_id'], 'eq.$_userId');
    });

    test('rangeForUser issues GET with gte/lte log_date', () async {
      final recorder = _Recorder();
      final httpClient = _makeMockClient(recorder, (req, body) {
        return http.Response(
          jsonEncode([_logRow()]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final repo = _makeLogsRepo(httpClient);

      final out = await repo.rangeForUser(
        DateTime(2026, 5, 1),
        DateTime(2026, 5, 31),
      );
      expect(out, hasLength(1));

      final req = recorder.requests.single;
      expect(req.method, 'GET');
      expect(req.url.queryParameters['user_id'], 'eq.$_userId');
      expect(req.url.queryParameters['log_date'], anyOf(
        contains('gte.2026-05-01'),
        contains('lte.2026-05-31'),
      ));
    });

    test('error responses bubble as RepositoryError', () async {
      final recorder = _Recorder();
      final httpClient = _makeMockClient(recorder, (req, body) {
        return http.Response(
          jsonEncode({'message': 'conflict', 'code': '409'}),
          409,
          headers: {'content-type': 'application/json'},
        );
      });
      final repo = _makeLogsRepo(httpClient);

      Object? caught;
      try {
        await repo.log(_habitId, DateTime(2026, 5, 7), HabitLogStatus.done);
      } catch (e) {
        caught = e;
      }
      expect(caught, isA<RepositoryError>());
    });
  });

  group('RepositoryError mapping', () {
    test('maps PostgrestException 401 to unauthorized', () {
      final mapped = RepositoryError.from(
        const PostgrestException(message: 'no', code: '401'),
      );
      expect(mapped, isA<RepositoryUnauthorizedError>());
    });

    test('maps PostgrestException 23505 to conflict', () {
      final mapped = RepositoryError.from(
        const PostgrestException(message: 'dup', code: '23505'),
      );
      expect(mapped, isA<RepositoryConflictError>());
    });

    test('maps AuthException to unauthorized', () {
      final mapped = RepositoryError.from(AuthException('auth'));
      expect(mapped, isA<RepositoryUnauthorizedError>());
    });

    test('falls back to unknown', () {
      final mapped = RepositoryError.from(Exception('weird'));
      expect(mapped, isA<RepositoryUnknownError>());
    });
  });
}
