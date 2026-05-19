import 'package:flutter/foundation.dart';

// JS interop is only available on Web. On other platforms we fall back to
// no-ops so the codebase compiles for desktop/mobile testing as well.
// ignore: avoid_web_libraries_in_flutter
import 'telegram_service_web.dart'
    if (dart.library.io) 'telegram_service_stub.dart';

/// Thin facade over the Telegram WebApp JS API.
///
/// Use [openInvoice] to start a Telegram Stars payment flow. The callback
/// receives a [TgInvoiceStatus] so callers can react to paid / cancelled /
/// failed states without dealing with raw strings.
class TelegramService {
  const TelegramService();

  /// Returns the raw `window.Telegram.WebApp.initData` string.
  /// Empty string when running outside Telegram (dev host, unit tests).
  String getInitData() {
    if (kIsWeb) {
      return getInitDataWeb();
    }
    return '';
  }

  /// Opens [url] in an external browser tab. On Web routes through
  /// `Telegram.WebApp.openLink` so Telegram can decide between in-app browser
  /// and OS handler. On non-Web platforms — no-op (used only in dev hosts).
  void openLink(String url) {
    if (kIsWeb) {
      openLinkWeb(url);
    }
  }

  /// Opens a Telegram Stars invoice in the current Mini App context.
  ///
  /// [invoiceUrl] — the link returned by the `create_invoice` Edge Function.
  /// [onStatus]  — called once with the result when the user closes the
  ///               payment sheet.
  ///
  /// On non-Web platforms (unit-test host, desktop) the callback is invoked
  /// immediately with [TgInvoiceStatus.failed] so callers can handle errors.
  void openInvoice(
    String invoiceUrl, {
    required void Function(TgInvoiceStatus status) onStatus,
  }) {
    if (kIsWeb) {
      openInvoiceWeb(invoiceUrl, onStatus);
    } else {
      onStatus(TgInvoiceStatus.failed);
    }
  }
}

/// Possible outcomes from a Telegram Stars invoice.
enum TgInvoiceStatus {
  paid,
  cancelled,
  failed,
  ;

  static TgInvoiceStatus fromString(String raw) => switch (raw) {
        'paid' => TgInvoiceStatus.paid,
        'cancelled' => TgInvoiceStatus.cancelled,
        _ => TgInvoiceStatus.failed,
      };
}
