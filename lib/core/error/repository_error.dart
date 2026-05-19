import 'package:supabase_flutter/supabase_flutter.dart';

/// Domain-level error returned by repositories.
///
/// Repositories wrap Supabase / network exceptions into one of these cases so
/// the presentation layer can branch on `kind` rather than match raw types.
sealed class RepositoryError implements Exception {
  const RepositoryError({this.cause, this.message});

  final Object? cause;
  final String? message;

  /// Network / transport failure (offline, timeout, DNS, etc).
  const factory RepositoryError.network({Object? cause, String? message}) =
      RepositoryNetworkError;

  /// Auth missing / expired / RLS denied.
  const factory RepositoryError.unauthorized({Object? cause, String? message}) =
      RepositoryUnauthorizedError;

  /// Unique constraint violation, optimistic-concurrency conflict, etc.
  const factory RepositoryError.conflict({Object? cause, String? message}) =
      RepositoryConflictError;

  /// Anything we did not specifically classify.
  const factory RepositoryError.unknown(Object cause, {String? message}) =
      RepositoryUnknownError;

  /// Maps an arbitrary thrown value into a [RepositoryError].
  ///
  /// The mapping is conservative: anything we don't recognise falls into
  /// [RepositoryError.unknown] so callers always receive a typed value.
  static RepositoryError from(Object error) {
    if (error is RepositoryError) return error;

    if (error is AuthException) {
      return RepositoryError.unauthorized(cause: error, message: error.message);
    }

    if (error is PostgrestException) {
      // PostgREST surfaces auth/RLS as 401 / 403 or PGRST301; conflicts as 409
      // / 23505. Codes are stringly-typed so we tolerate either form.
      final status = error.code;
      final code = status?.toString();
      if (code == '401' || code == '403' || code == 'PGRST301') {
        return RepositoryError.unauthorized(
          cause: error,
          message: error.message,
        );
      }
      if (code == '409' || code == '23505') {
        return RepositoryError.conflict(cause: error, message: error.message);
      }
      return RepositoryError.unknown(error, message: error.message);
    }

    final type = error.runtimeType.toString();
    if (type.contains('SocketException') ||
        type.contains('ClientException') ||
        type.contains('TimeoutException') ||
        type.contains('HttpException')) {
      return RepositoryError.network(cause: error, message: error.toString());
    }

    return RepositoryError.unknown(error, message: error.toString());
  }

  @override
  String toString() {
    final cls = runtimeType.toString();
    return message == null ? cls : '$cls: $message';
  }
}

final class RepositoryNetworkError extends RepositoryError {
  const RepositoryNetworkError({super.cause, super.message});
}

final class RepositoryUnauthorizedError extends RepositoryError {
  const RepositoryUnauthorizedError({super.cause, super.message});
}

final class RepositoryConflictError extends RepositoryError {
  const RepositoryConflictError({super.cause, super.message});
}

final class RepositoryUnknownError extends RepositoryError {
  const RepositoryUnknownError(Object cause, {super.message})
      : super(cause: cause);
}
