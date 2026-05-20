// Web implementation: read the IANA timezone name from the browser via
// `Intl.DateTimeFormat().resolvedOptions().timeZone`. This is the only
// reliable source — `DateTime.timeZoneName` on dart2js is locale-formatted
// and not safe to feed into Postgres' `AT TIME ZONE`.
import 'dart:js_interop';

@JS('Intl.DateTimeFormat')
external _DTF _intlDateTimeFormat();

extension type _DTF._(JSObject _) implements JSObject {
  external _ResolvedOptions resolvedOptions();
}

extension type _ResolvedOptions._(JSObject _) implements JSObject {
  external String? get timeZone;
}

/// Returns the browser's IANA timezone name (e.g. `Asia/Almaty`) or an empty
/// string when the API is missing or throws. Callers MUST treat `''` as
/// "unknown — do nothing".
String detectIanaTimeZone() {
  try {
    return _intlDateTimeFormat().resolvedOptions().timeZone ?? '';
  } catch (_) {
    return '';
  }
}
