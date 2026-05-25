import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hiddify/core/http_client/dio_http_client.dart';
import 'package:hiddify/features/profile/model/profile_failure.dart';

class TiinApiClient {
  static const String baseUrl = 'https://344988.snk.wtf';
  static const String subscribePath = '/sub/';

  final DioHttpClient _httpClient;

  TiinApiClient({required DioHttpClient httpClient}) : _httpClient = httpClient;

  String buildSubscriptionUrl(String token) {
    return '$baseUrl$subscribePath$token';
  }

  TaskEither<ProfileFailure, String> fetchSubscription({
    required String token,
    CancelToken? cancelToken,
  }) {
    final url = buildSubscriptionUrl(token);
    return TaskEither.tryCatch(() async {
      final response = await _httpClient.get(
        url,
        cancelToken: cancelToken,
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is String) {
          return data;
        }
        return jsonEncode(data);
      }
      throw ProfileFailure.unexpected(
        'HTTP ${response.statusCode}',
      );
    }, (err, st) {
      if (err is ProfileFailure) return err;
      return ProfileFailure.unexpected(err, st);
    });
  }

  TaskEither<ProfileFailure, List<String>> fetchAndDecodeProxies({
    required String token,
    CancelToken? cancelToken,
  }) {
    return fetchSubscription(token: token, cancelToken: cancelToken).flatMap(
      (rawContent) => TaskEither.fromEither(
        _decodeSubscription(rawContent),
      ),
    );
  }

  Either<ProfileFailure, List<String>> _decodeSubscription(String rawContent) {
    try {
      final trimmed = rawContent.trim();
      if (trimmed.isEmpty) {
        return const Left(ProfileFailure.unexpected('Empty subscription'));
      }

      List<String> proxies;

      if (_isBase64Content(trimmed)) {
        try {
          final decoded = utf8.decode(base64.decode(trimmed));
          proxies = decoded.split('\n').where((l) => l.trim().isNotEmpty).toList();
        } catch (_) {
          proxies = trimmed.split('\n').where((l) => l.trim().isNotEmpty).toList();
        }
      } else {
        proxies = trimmed.split('\n').where((l) => l.trim().isNotEmpty).toList();
      }

      if (proxies.isEmpty) {
        return const Left(ProfileFailure.unexpected('No proxies found'));
      }

      return Right(proxies);
    } catch (e) {
      return Left(ProfileFailure.unexpected(e));
    }
  }

  bool _isBase64Content(String content) {
    final cleaned = content.replaceAll('\n', '').replaceAll('\r', '').replaceAll(' ', '');
    final base64Regex = RegExp(r'^[A-Za-z0-9+/]*={0,2}$');
    return cleaned.length > 20 && base64Regex.hasMatch(cleaned);
  }
}
