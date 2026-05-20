// Facade for IANA-timezone detection.
//
// Flutter Web exposes `Intl.DateTimeFormat().resolvedOptions().timeZone`
// via JS interop, which returns a real IANA name (e.g. `Asia/Almaty`).
// `DateTime.timeZoneName` in dart2js gives an unstable, non-IANA string —
// useless for `AT TIME ZONE` on the server. The web variant uses
// js_interop; the io stub returns '' so the codebase still compiles for
// tests and analysis on non-web hosts.
// ignore: avoid_web_libraries_in_flutter
export 'timezone_web.dart'
    if (dart.library.io) 'timezone_stub.dart';
