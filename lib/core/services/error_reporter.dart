import 'dart:collection';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../config/env.dart';

class ErrorReport {
  ErrorReport(this.timestamp, this.message, this.stack, {this.context});

  final DateTime timestamp;
  final String message;
  final String? stack;
  final String? context;

  String format() {
    final ctx = context != null ? ' [$context]' : '';
    return '${timestamp.toIso8601String()}$ctx $message'
        '${stack != null ? '\n$stack' : ''}';
  }
}

class ErrorReporter {
  ErrorReporter._({int capacity = 200}) : _capacity = capacity;

  static final ErrorReporter instance = ErrorReporter._();

  final int _capacity;
  final Queue<ErrorReport> _buffer = Queue<ErrorReport>();

  List<ErrorReport> get buffer => List.unmodifiable(_buffer);

  void captureException(Object error, StackTrace? stack, {String? context}) {
    final report = ErrorReport(
      DateTime.now(),
      error.toString(),
      stack?.toString(),
      context: context,
    );
    _buffer.addLast(report);
    while (_buffer.length > _capacity) {
      _buffer.removeFirst();
    }
    dev.log(
      report.message,
      name: context ?? 'app',
      error: error,
      stackTrace: stack,
    );
    // Fire-and-forget POST to the dev log sink. Production builds skip
    // this — the function is only mounted in local Supabase.
    if (!Env.isProduction) {
      _forwardRemote(report, level: 'ERROR');
    }
  }

  /// Forward a non-error log line to the same sink (dev only). Useful for
  /// `print`-style breadcrumbs during a runtime hunt.
  void log(String message, {String? context, String level = 'INFO'}) {
    final report = ErrorReport(
      DateTime.now(),
      message,
      null,
      context: context,
    );
    _buffer.addLast(report);
    while (_buffer.length > _capacity) {
      _buffer.removeFirst();
    }
    dev.log(message, name: context ?? 'app');
    if (!Env.isProduction) {
      _forwardRemote(report, level: level);
    }
  }

  Future<void> _forwardRemote(ErrorReport r, {required String level}) async {
    final url = Env.supabaseUrl;
    if (url.isEmpty) return;
    try {
      await http.post(
        Uri.parse('$url/functions/v1/log_client'),
        headers: const {'content-type': 'application/json'},
        body: jsonEncode({
          'level': level,
          'context': r.context,
          'message': r.message,
          'stack': r.stack,
          'ts': r.timestamp.toIso8601String(),
        }),
      );
    } catch (_) {
      // Swallow — sink is best-effort. We don't want a logging failure
      // to mask the original error in dev consoles.
    }
  }

  String exportText() => _buffer.map((r) => r.format()).join('\n\n');

  Future<void> copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: exportText()));
  }

  void clear() => _buffer.clear();

  static void install() {
    FlutterError.onError = (details) {
      instance.captureException(
        details.exception,
        details.stack,
        context: 'flutter',
      );
      if (kDebugMode) FlutterError.presentError(details);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      instance.captureException(error, stack, context: 'platform');
      return true;
    };
  }
}
