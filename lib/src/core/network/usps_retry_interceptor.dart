import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';

/// Interceptor that retries failed idempotent HTTP requests with exponential backoff.
class UspsRetryInterceptor extends Interceptor {
  /// The underlying [Dio] instance used to replay requests.
  final Dio dio;

  /// Maximum number of retry attempts per request.
  final int maxRetries;

  /// Initial base delay before the first retry.
  final Duration initialDelay;

  /// Backoff multiplier applied to each subsequent retry attempt.
  final double backoffMultiplier;

  /// HTTP status codes considered transient and eligible for retry.
  final Set<int> retryStatusCodes;

  /// HTTP methods considered safe/idempotent to retry.
  final Set<String> retryMethods;

  /// Optional custom sleeper for testing or controlling delays.
  final Future<void> Function(Duration duration) sleeper;

  /// Creates a new [UspsRetryInterceptor].
  UspsRetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.backoffMultiplier = 2.0,
    Set<int>? retryStatusCodes,
    Set<String>? retryMethods,
    Future<void> Function(Duration duration)? sleeper,
  }) : retryStatusCodes =
           retryStatusCodes ?? const {429, 500, 502, 503, 504},
       retryMethods = retryMethods ?? const {'GET', 'HEAD', 'OPTIONS'},
       sleeper = sleeper ?? Future<void>.delayed;

  static const String _retryCountKey = 'usps_retry_count';

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    final method = requestOptions.method.toUpperCase();

    // Check if the request method is eligible for retry
    if (!retryMethods.contains(method)) {
      return handler.next(err);
    }

    final currentAttempt = (requestOptions.extra[_retryCountKey] as int?) ?? 0;
    if (currentAttempt >= maxRetries) {
      return handler.next(err);
    }

    // Check if error is transient
    final statusCode = err.response?.statusCode;
    final isTransient =
        _isTransientNetworkError(err.type) ||
        (statusCode != null && retryStatusCodes.contains(statusCode));

    if (!isTransient) {
      return handler.next(err);
    }

    // Calculate delay with exponential backoff
    final nextAttempt = currentAttempt + 1;
    final delayMs = (initialDelay.inMilliseconds *
            pow(backoffMultiplier, currentAttempt))
        .toInt();
    final delay = Duration(milliseconds: delayMs);

    requestOptions.extra[_retryCountKey] = nextAttempt;

    await sleeper(delay);

    try {
      final response = await dio.fetch<dynamic>(requestOptions);
      return handler.resolve(response);
    } on DioException catch (retryErr) {
      return onError(retryErr, handler);
    }
  }

  bool _isTransientNetworkError(DioExceptionType type) {
    switch (type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      default:
        return false;
    }
  }
}
