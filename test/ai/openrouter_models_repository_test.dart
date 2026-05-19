import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/core/localization/generated/app_localizations.dart';
import 'package:habit_flow/features/ai/data/openrouter_models_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

class _FakeRequestOptions extends Fake implements RequestOptions {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeRequestOptions());
    registerFallbackValue(Options());
  });

  group('OpenRouterModelInfo.fromJson', () {
    test('marks free=true and parses fields', () {
      final m = OpenRouterModelInfo.fromJson({
        'id': 'openai/gpt-oss-120b:free',
        'name': 'GPT-OSS 120B',
        'context_length': 131072,
        'pricing': {'prompt': '0', 'completion': '0'},
        'free': true,
      });
      expect(m.id, 'openai/gpt-oss-120b:free');
      expect(m.name, 'GPT-OSS 120B');
      expect(m.contextLength, 131072);
      expect(m.free, isTrue);
      expect(m.completionPrice, '0');
    });

    test('paid model has free=false and price strings', () {
      final m = OpenRouterModelInfo.fromJson({
        'id': 'openai/gpt-4o',
        'name': 'GPT-4o',
        'context_length': 128000,
        'pricing': {'prompt': '0.0000025', 'completion': '0.00001'},
        'free': false,
      });
      expect(m.free, isFalse);
      expect(m.promptPrice, '0.0000025');
      expect(m.completionPrice, '0.00001');
    });

    test('falls back to id when name missing', () {
      final m = OpenRouterModelInfo.fromJson({
        'id': 'foo/bar',
        'free': true,
      });
      expect(m.name, 'foo/bar');
      expect(m.contextLength, isNull);
    });
  });

  group('OpenRouterModelsRepository.list', () {
    late _MockDio dio;
    late OpenRouterModelsRepository repo;

    setUp(() {
      dio = _MockDio();
      repo = OpenRouterModelsRepository(
        dio: dio,
        baseUrl: 'https://supabase.test',
        anonKey: 'anon',
      );
    });

    test('parses models array from Edge Function response', () async {
      when(
        () => dio.post<Map<String, dynamic>>(
          any(),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: {
            'data': [
              {
                'id': 'a/free',
                'name': 'A Free',
                'context_length': 32000,
                'pricing': {'prompt': '0', 'completion': '0'},
                'free': true,
              },
              {
                'id': 'b/paid',
                'name': 'B Paid',
                'context_length': 200000,
                'pricing': {'prompt': '0.000003', 'completion': '0.000015'},
                'free': false,
              },
            ],
          },
        ),
      );

      final list = await repo.list();
      expect(list, hasLength(2));
      expect(list.where((m) => m.free).map((m) => m.id), ['a/free']);
      expect(list.where((m) => !m.free).map((m) => m.id), ['b/paid']);
    });

    test('returns empty when data field is missing', () async {
      when(
        () => dio.post<Map<String, dynamic>>(
          any(),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: const {},
        ),
      );

      expect(await repo.list(), isEmpty);
    });
  });

  group('Model row UI — free badge rendering', () {
    testWidgets('Free badge text shows on a free entry', (tester) async {
      // We render a minimal Material wrapper around a small list that uses the
      // same FREE-badge keyword the section emits. The label comes from the
      // localization bundle, so we mount AppLocalizations as well.
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('en'),
            home: Scaffold(body: _ProbeFreeBadge()),
          ),
        ),
      );
      await tester.pump();

      // The widget contains a free model — assert that the FREE label
      // (English: "FREE", Russian: "БЕСПЛАТНО") shows up exactly once.
      expect(find.text('FREE'), findsOneWidget);
    });
  });

  // Smoke check that the repository class is wired into the providers map.
  group('providers', () {
    test('availableModelsProvider exists and is a FutureProvider', () {
      expect(availableModelsProvider, isA<FutureProvider<dynamic>>());
    });
  });
}

/// A tiny widget that mimics a single row from the model section: a model name
/// followed by the [aiBadgeFree] localised label. This lets us verify that the
/// free badge text resolves from the same loc bundle the real screen uses,
/// without booting the entire AiSettingsScreen + Supabase stack.
class _ProbeFreeBadge extends StatelessWidget {
  const _ProbeFreeBadge();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Row(
      children: [
        const Text('GPT-OSS 120B'),
        const SizedBox(width: 7),
        Text(loc.aiBadgeFree),
      ],
    );
  }
}
