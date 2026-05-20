// Non-Web stub. JS interop is not available, and the Mini App only runs on
// Web in production. Returning '' tells callers to leave `users.timezone`
// alone (so unit tests and `flutter analyze` on the VM stay green).
String detectIanaTimeZone() => '';
