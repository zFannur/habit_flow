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

// ── Telegram chrome: viewport, theme, native BackButton ─────────────────────
// See https://core.telegram.org/bots/webapps#initializing-mini-apps

@JS('Telegram.WebApp.ready')
external void _ready();

@JS('Telegram.WebApp.expand')
external void _expand();

@JS('Telegram.WebApp.colorScheme')
external JSString? get _colorScheme;

@JS('Telegram.WebApp.setHeaderColor')
external void _setHeaderColor(JSString color);

@JS('Telegram.WebApp.setBackgroundColor')
external void _setBackgroundColor(JSString color);

@JS('Telegram.WebApp.onEvent')
external void _onEvent(JSString event, JSFunction cb);

@JS('Telegram.WebApp.offEvent')
external void _offEvent(JSString event, JSFunction cb);

@JS('Telegram.WebApp.BackButton.show')
external void _backButtonShow();

@JS('Telegram.WebApp.BackButton.hide')
external void _backButtonHide();

@JS('Telegram.WebApp.BackButton.onClick')
external void _backButtonOnClick(JSFunction cb);

@JS('Telegram.WebApp.BackButton.offClick')
external void _backButtonOffClick(JSFunction cb);

/// Telegram-функции активны только в реальной Mini App сессии (есть initData).
/// В standalone-браузере `telegram-web-app.js` всё равно создаёт объект
/// `Telegram.WebApp` (с `colorScheme: 'light'`), поэтому без этой проверки
/// «снаружи Telegram» приложение ошибочно форсило бы светлую тему и показывало
/// нативную кнопку «Назад».
bool _inTelegram() {
  try {
    final d = _initData?.toDart;
    return d != null && d.isNotEmpty;
  } catch (_) {
    return false;
  }
}

void tgInitChrome() {
  if (!_inTelegram()) return;
  try {
    _ready();
    _expand();
  } catch (_) {
    // noop
  }
}

String? tgColorScheme() {
  if (!_inTelegram()) return null;
  try {
    return _colorScheme?.toDart;
  } catch (_) {
    return null;
  }
}

void tgSetChromeColors(String headerHex, String backgroundHex) {
  if (!_inTelegram()) return;
  try {
    _setHeaderColor(headerHex.toJS);
    _setBackgroundColor(backgroundHex.toJS);
  } catch (_) {
    // Старые клиенты (<6.9) не принимают hex в setHeaderColor — молча пропускаем.
  }
}

void Function() tgOnThemeChanged(void Function() cb) {
  if (!_inTelegram()) return () {};
  try {
    final jsCb = (() => cb()).toJS;
    _onEvent('themeChanged'.toJS, jsCb);
    return () {
      try {
        _offEvent('themeChanged'.toJS, jsCb);
      } catch (_) {
        // noop
      }
    };
  } catch (_) {
    return () {};
  }
}

void Function() tgShowBackButton(void Function() onClick) {
  if (!_inTelegram()) return () {};
  try {
    final jsCb = (() => onClick()).toJS;
    _backButtonOnClick(jsCb);
    _backButtonShow();
    return () {
      try {
        _backButtonOffClick(jsCb);
        _backButtonHide();
      } catch (_) {
        // noop
      }
    };
  } catch (_) {
    return () {};
  }
}

void tgHideBackButton() {
  if (!_inTelegram()) return;
  try {
    _backButtonHide();
  } catch (_) {
    // noop
  }
}
