import 'package:flutter/foundation.dart';

// JS interop is only available on Web. On other platforms we fall back to
// no-ops or url_launcher so the codebase compiles and runs for desktop/mobile testing.
// ignore: avoid_web_libraries_in_flutter
import 'telegram_service_web.dart'
    if (dart.library.io) 'telegram_service_mobile.dart';

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
  /// and OS handler. On non-Web platforms — uses url_launcher.
  void openLink(String url) {
    if (kIsWeb) {
      openLinkWeb(url);
    } else {
      openLinkWeb(url); // delegates to launchUrl in telegram_service_mobile.dart
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

  /// Opens a deep link to the Telegram bot to pair the device.
  /// Used only on mobile/desktop. On Web, this is a no-op since the
  /// user is already in the Mini App.
  Future<void> openBotDeepLink(String token) async {
    if (!kIsWeb) {
      await openBotDeepLinkPlatform(token);
    }
  }

  // ── Telegram chrome (viewport / theme / native BackButton) ────────────────
  // Web-only; no-ops everywhere else. See SPEC §4 + app/CLAUDE.md
  // («Тема … перекрывается Telegram.WebApp.themeParams через TelegramService»).

  /// Signals readiness and expands the Mini App to full viewport
  /// (`WebApp.ready()` + `WebApp.expand()`). Call once at startup.
  void initChrome() {
    if (kIsWeb) tgInitChrome();
  }

  /// Telegram's current color scheme as a [Brightness], or `null` outside a
  /// real Mini App session (so the app falls back to platform brightness).
  Brightness? telegramBrightness() {
    if (!kIsWeb) return null;
    return switch (tgColorScheme()) {
      'dark' => Brightness.dark,
      'light' => Brightness.light,
      _ => null,
    };
  }

  /// Paints Telegram's native header and background (hex `#rrggbb`) so the
  /// webview edges match the app surface.
  void setChromeColors({
    required String headerHex,
    required String backgroundHex,
  }) {
    if (kIsWeb) tgSetChromeColors(headerHex, backgroundHex);
  }

  /// Subscribes to Telegram's `themeChanged` event. Returns a disposer that
  /// removes the listener.
  VoidCallback onThemeChanged(VoidCallback callback) =>
      kIsWeb ? tgOnThemeChanged(callback) : () {};

  /// Shows the native Telegram BackButton wired to [onClick]. Returns a
  /// disposer that unbinds the handler and hides the button.
  VoidCallback showBackButton(VoidCallback onClick) =>
      kIsWeb ? tgShowBackButton(onClick) : () {};

  /// Hides the native Telegram BackButton.
  void hideBackButton() {
    if (kIsWeb) tgHideBackButton();
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
