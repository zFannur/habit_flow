import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import '../../../core/config/env.dart';
import '../domain/auth_state.dart';

class DeviceLinkResponse {
  final String token;
  final String deepLink;
  final DateTime expiresAt;

  DeviceLinkResponse({
    required this.token,
    required this.deepLink,
    required this.expiresAt,
  });

  factory DeviceLinkResponse.fromJson(Map<String, dynamic> json) {
    // Server returns snake_case (see supabase/functions/auth_device_link/index.ts).
    return DeviceLinkResponse(
      token: json['token'] as String,
      deepLink: json['deep_link'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }
}

sealed class DeviceLinkPollResponse {
  const DeviceLinkPollResponse();
}

class DeviceLinkPollPending extends DeviceLinkPollResponse {
  const DeviceLinkPollPending();
}

class DeviceLinkPollSuccess extends DeviceLinkPollResponse {
  final String jwt;
  final AuthUser user;

  const DeviceLinkPollSuccess({required this.jwt, required this.user});
}

class DeviceLinkPollExpired extends DeviceLinkPollResponse {
  const DeviceLinkPollExpired();
}

class DeviceLinkPollConsumed extends DeviceLinkPollResponse {
  const DeviceLinkPollConsumed();
}

class DeviceLinkPollRateLimited extends DeviceLinkPollResponse {
  const DeviceLinkPollRateLimited();
}

class DeviceLinkRepository {
  DeviceLinkRepository({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  String get _endpoint => '${Env.supabaseUrl}/functions/v1/auth_device_link';

  Map<String, String> get _headers => <String, String>{
        'apikey': Env.supabaseAnonKey,
        'Authorization': 'Bearer ${Env.supabaseAnonKey}',
        'Content-Type': 'application/json',
      };

  /// Request a new device link token from the backend.
  Future<DeviceLinkResponse> createToken() async {
    try {
      dev.log('createToken → POST $_endpoint', name: 'device-link'); // DEBUG device-link
      final response = await _dio.post<dynamic>(
        _endpoint,
        data: <String, dynamic>{'action': 'create'},
        options: Options(headers: _headers),
      );
      dev.log(
        'createToken ← ${response.statusCode} body=${response.data}',
        name: 'device-link',
      ); // DEBUG device-link

      if (response.statusCode != 200 || response.data is! Map) {
        throw Exception('Failed to create device link token: status ${response.statusCode}');
      }

      final body = (response.data as Map).cast<String, dynamic>();
      return DeviceLinkResponse.fromJson(body);
    } on DioException catch (e) {
      dev.log(
        'createToken DioException type=${e.type} status=${e.response?.statusCode} body=${e.response?.data} msg=${e.message}',
        name: 'device-link',
        error: e,
      ); // DEBUG device-link
      throw Exception('Network error during token creation: ${e.message ?? e.type.name}');
    }
  }

  /// Poll the status of the device link token.
  Future<DeviceLinkPollResponse> pollToken(String token) async {
    try {
      dev.log('pollToken → POST token=${token.substring(0, 6)}…', name: 'device-link'); // DEBUG device-link
      final response = await _dio.post<dynamic>(
        _endpoint,
        data: <String, dynamic>{
          'action': 'poll',
          'token': token,
        },
        options: Options(headers: _headers),
      );
      dev.log(
        'pollToken ← ${response.statusCode} body=${response.data}',
        name: 'device-link',
      ); // DEBUG device-link

      if (response.statusCode != 200 || response.data is! Map) {
        throw Exception('Failed to poll device link token: status ${response.statusCode}');
      }

      final body = (response.data as Map).cast<String, dynamic>();
      final status = body['status'] as String?;

      switch (status) {
        case 'pending':
          return const DeviceLinkPollPending();
        case 'linked':
          final jwt = body['jwt'] as String?;
          final userJson = body['user'] as Map?;
          if (jwt == null || userJson == null) {
            throw Exception('auth_device_link poll returned linked status but missing jwt or user');
          }
          final user = AuthUser.fromJson(userJson.cast<String, dynamic>());
          return DeviceLinkPollSuccess(jwt: jwt, user: user);
        case 'expired':
          return const DeviceLinkPollExpired();
        case 'consumed':
          return const DeviceLinkPollConsumed();
        default:
          throw Exception('Unknown device link status: $status');
      }
    } on DioException catch (e) {
      dev.log(
        'pollToken DioException type=${e.type} status=${e.response?.statusCode} body=${e.response?.data} msg=${e.message}',
        name: 'device-link',
        error: e,
      ); // DEBUG device-link
      if (e.response?.statusCode == 429) {
        return const DeviceLinkPollRateLimited();
      }
      throw Exception('Network error during token polling: ${e.message ?? e.type.name}');
    }
  }
}
