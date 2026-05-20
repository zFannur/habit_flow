import 'dart:js_interop';

import 'telegram_service.dart';

// JS interop declarations for Telegram.WebApp.openInvoice.
// See https://core.telegram.org/bots/webapps#initializing-mini-apps

@JS('Telegram.WebApp.openInvoice')
external void _openInvoice(JSString url, JSFunction callback);

@JS('Telegram.WebApp.openLink')
external void _openLink(JSString url);

@JS('window.open')
external JSAny? _windowOpen(JSString url, JSString target);

@JS('Telegram.WebApp.initData')
external JSString? get _initData;

void openInvoiceWeb(
  String invoiceUrl,
  void Function(TgInvoiceStatus status) onStatus,
) {
  _openInvoice(
    invoiceUrl.toJS,
    ((JSString rawStatus) {
      onStatus(TgInvoiceStatus.fromString(rawStatus.toDart));
    }).toJS,
  );
}

void openLinkWeb(String url) {
  try {
    _openLink(url.toJS);
  } catch (_) {
    // Telegram.WebApp not available (standalone Chrome) — fall back to
    // a regular browser tab.
    _windowOpen(url.toJS, '_blank'.toJS);
  }
}

String getInitDataWeb() {
  try {
    return _initData?.toDart ?? '';
  } catch (_) {
    // Telegram.WebApp not available (standalone Chrome / no Mini App context).
    return '';
  }
}

Future<void> openBotDeepLinkPlatform(String token) async {}
