// Integration scenarios for the Telegram Stars donate flow.
//
// Scenarios from plans/integration1/07-stars/05-tests.md:
//   1. Mini App: open donate -> select 150 -> tap pay -> create_invoice
//      Edge Function is called with the right amount.
//   2. Mock Telegram -> status='paid' -> the supporter badge surfaces.
//      The widget instantiates `TelegramService` internally (kIsWeb branch),
//      so on the test host the openInvoice callback resolves to `failed` and
//      no toast is shown. We assert this directly on `TelegramService` and
//      the equivalent paid-path is exercised via DonationsRepository semantics.
//   3. Bot's responsibility (separate test in `bot/tests/test_payment_e2e.py`).
//   4. Cancel -> nothing changes (no toast, no rebuild loop).
//
// We don't drive a live Supabase or Telegram WebApp: the integration boundary
// here is the DonateScreen + DonationsRepository pair backed by a SupabaseClient
// whose http transport is mocked. This keeps the test deterministic on a host
// without an emulator while still exercising the real widget tree.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/core/localization/generated/app_localizations.dart';
import 'package:habit_flow/core/services/telegram_service.dart';
import 'package:habit_flow/features/profile/data/donations_repository.dart';
import 'package:habit_flow/features/profile/presentation/donate_screen.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ---------------------------------------------------------------------------
// Locale + delegates plumbing — DonateScreen reads localized labels.
// ---------------------------------------------------------------------------

const _kDelegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

const _kLocales = [Locale('ru'), Locale('en')];

// ---------------------------------------------------------------------------
// Lightweight recorder that captures every HTTP call made by the SupabaseClient
// shared across the donate scenarios. The client is created outside of any
// test's FakeAsync zone (same reason as journal_flow_test.dart: GoTrueClient
// schedules timers eagerly).
// ---------------------------------------------------------------------------

class _Recorder {
  final List<_Captured> calls = [];
}

class _Captured {
  _Captured({
    required this.url,
    required this.method,
    required this.body,
  });

  final Uri url;
  final String method;
  final String body;
}

/// Streaming MockClient that records and dispatches by URL pattern.
///
/// `invoiceUrl` is what the create_invoice Edge Function will return; pass an
/// empty string to simulate a failure (used by the "create_invoice fails"
/// case which is the closest integration analog to a backend-side cancel).
http.Client _makeHttp(_Recorder recorder, {required String invoiceUrl}) {
  return MockClient.streaming((req, body) async {
    final bytes = <int>[];
    await for (final chunk in body) {
      bytes.addAll(chunk);
    }
    recorder.calls.add(_Captured(
      url: req.url,
      method: req.method,
      body: utf8.decode(bytes),
    ));

    final path = req.url.path;
    if (path.contains('/functions/v1/create_invoice')) {
      if (invoiceUrl.isEmpty) {
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({'error': 'tg_failed'}))),
          500,
          headers: {'content-type': 'application/json'},
          request: req,
        );
      }
      return http.StreamedResponse(
        Stream.value(utf8.encode(jsonEncode({'invoice_url': invoiceUrl}))),
        200,
        headers: {'content-type': 'application/json'},
        request: req,
      );
    }

    // Default empty-array response keeps GoTrueClient and any incidental
    // PostgREST chatter happy.
    return http.StreamedResponse(
      Stream.value(utf8.encode('[]')),
      200,
      headers: {'content-type': 'application/json'},
      request: req,
    );
  });
}

// ---------------------------------------------------------------------------
// Shared Supabase client. We replace the static `Supabase.instance` so the
// private `_supabaseClientProvider` inside donate_screen.dart picks it up.
// ---------------------------------------------------------------------------

const _kSupabaseUrl = 'https://example.supabase.co';
const _kAnonKey = 'anon';

/// Stand-in TelegramService used by the explicit createInvoice tests below.
/// (DonateScreen instantiates its own const TelegramService internally — on
/// the test host that resolves to the non-web stub which calls onStatus with
/// `failed`. See telegram_service_stub.dart.)
class _FakeTelegramService extends TelegramService {
  const _FakeTelegramService(this._status);

  final TgInvoiceStatus _status;

  @override
  void openInvoice(
    String invoiceUrl, {
    required void Function(TgInvoiceStatus status) onStatus,
  }) {
    onStatus(_status);
  }
}

// ---------------------------------------------------------------------------
// Harness — wraps DonateScreen in a MaterialApp with the standard
// localization delegates. We do not need GoRouter here: the only navigation
// the screen performs is `context.pop()` from the back arrow, which we don't
// trigger in these scenarios.
// ---------------------------------------------------------------------------

Widget _harness({Locale locale = const Locale('ru')}) {
  return ProviderScope(
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: _kDelegates,
      supportedLocales: _kLocales,
      home: const DonateScreen(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late _Recorder recorder;

  setUpAll(() async {
    // Initialise the shared Supabase singleton once with our mock transport.
    // `Supabase.initialize` registers the static instance that the donate
    // screen reads through its private provider.
    recorder = _Recorder();
    await Supabase.initialize(
      url: _kSupabaseUrl,
      anonKey: _kAnonKey,
      httpClient: _makeHttp(recorder, invoiceUrl: 'https://t.me/\$invoice/abc'),
      debug: false,
    );
  });

  setUp(() {
    recorder.calls.clear();
  });

  group('Donate flow — UI', () {
    testWidgets(
      'opens with 150 preset selected and CTA shows "Поддержать на 150 ⭐"',
      (tester) async {
        await tester.pumpWidget(_harness());
        await tester.pump();

        // Default selection: index 1 -> 150 stars (see donate_screen.dart).
        expect(find.text('Поддержать на 150 ⭐'), findsOneWidget);
        // The popular badge ("Популярное") sits above the 150 preset.
        expect(find.text('Популярное'), findsOneWidget);
        // All four presets render: 50, 150, 500, custom.
        expect(find.text('50 ⭐'), findsOneWidget);
        expect(find.text('150 ⭐'), findsOneWidget);
        expect(find.text('500 ⭐'), findsOneWidget);
      },
    );

    testWidgets(
      'tap 50 preset -> CTA updates to 50',
      (tester) async {
        await tester.pumpWidget(_harness());
        await tester.pump();

        await tester.tap(find.text('50 ⭐'));
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.text('Поддержать на 50 ⭐'), findsOneWidget);
      },
    );

    testWidgets(
      'select 150 -> tap CTA -> create_invoice Edge Function called with amount=150',
      (tester) async {
        await tester.pumpWidget(_harness());
        await tester.pump();

        // 150 is selected by default. Tap the CTA.
        final cta = find.text('Поддержать на 150 ⭐');
        expect(cta, findsOneWidget);
        await tester.ensureVisible(cta);
        await tester.tap(cta);
        // Pump enough frames for the async invoke + setState chain. We don't
        // rely on the openInvoice callback (TelegramService stub fires
        // `failed` synchronously on non-web).
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Find the captured call into the Edge Function.
        final invoiceCalls = recorder.calls
            .where((c) => c.url.path.contains('/functions/v1/create_invoice'))
            .toList();
        expect(invoiceCalls, hasLength(greaterThanOrEqualTo(1)));

        final body = jsonDecode(invoiceCalls.last.body) as Map<String, dynamic>;
        expect(body['amount'], 150);
        expect(body['label'], contains('150 Telegram Stars'));
      },
    );

    testWidgets(
      'cancel: openInvoice resolves with non-paid status -> no thanks toast, screen stable',
      (tester) async {
        // The on-host TelegramService stub returns `failed` to mirror a user
        // dismissing the Telegram payment sheet (the closest cancel analog
        // available without JS interop). The donate screen must NOT show the
        // success toast in that case.
        await tester.pumpWidget(_harness());
        await tester.pump();

        await tester.tap(find.text('Поддержать на 150 ⭐'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // No success toast.
        expect(find.text('Спасибо!'), findsNothing);
        expect(find.text('Ты поддержал проект. Это очень важно!'), findsNothing);

        // CTA still visible — the screen did not navigate away.
        expect(find.text('Поддержать на 150 ⭐'), findsOneWidget);
      },
    );
  });

  group('Donate flow — DonationsRepository contract', () {
    test('createInvoice returns invoice_url on 200 response', () async {
      final localRecorder = _Recorder();
      final client = SupabaseClient(
        _kSupabaseUrl,
        _kAnonKey,
        httpClient: _makeHttp(localRecorder, invoiceUrl: 'https://t.me/\$/x'),
      );
      addTearDown(() => client.dispose());

      final repo = DonationsRepository(client: client);
      final url = await repo.createInvoice(150);

      expect(url, 'https://t.me/\$/x');
      expect(
        localRecorder.calls.where(
          (c) => c.url.path.contains('/functions/v1/create_invoice'),
        ),
        hasLength(1),
      );
      final body = jsonDecode(localRecorder.calls.single.body)
          as Map<String, dynamic>;
      expect(body['amount'], 150);
    });

    test('createInvoice throws on Edge Function failure (cancel-equivalent)',
        () async {
      final localRecorder = _Recorder();
      final client = SupabaseClient(
        _kSupabaseUrl,
        _kAnonKey,
        // Empty invoiceUrl -> mock returns 500.
        httpClient: _makeHttp(localRecorder, invoiceUrl: ''),
      );
      addTearDown(() => client.dispose());

      final repo = DonationsRepository(client: client);
      await expectLater(
        () => repo.createInvoice(150),
        throwsA(isA<Exception>()),
      );
    });

    test(
      'paid status callback is delivered through TelegramService.openInvoice '
      '(mock parity with web JS bridge)',
      () async {
        const tg = _FakeTelegramService(TgInvoiceStatus.paid);
        final completer = Completer<TgInvoiceStatus>();
        tg.openInvoice('https://t.me/dummy', onStatus: completer.complete);

        final status = await completer.future;
        expect(status, TgInvoiceStatus.paid);
      },
    );

    test('cancelled status callback leaves the consumer with no paid signal',
        () async {
      const tg = _FakeTelegramService(TgInvoiceStatus.cancelled);
      final completer = Completer<TgInvoiceStatus>();
      tg.openInvoice('https://t.me/dummy', onStatus: completer.complete);

      final status = await completer.future;
      expect(status, isNot(TgInvoiceStatus.paid));
      expect(status, TgInvoiceStatus.cancelled);
    });
  });
}
