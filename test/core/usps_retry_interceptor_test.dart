import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:usps_v3_dart/usps_v3_dart.dart';

void main() {
  group('UspsRetryInterceptor', () {
    late Dio dio;
    late List<Duration> sleepDelays;
    int callCount = 0;

    setUp(() {
      callCount = 0;
      sleepDelays = [];
      dio = Dio();
    });

    test('retries transient 503 error and succeeds on subsequent try', () async {
      dio.httpClientAdapter = _MockAdapter((options) {
        callCount++;
        if (callCount == 1) {
          return ResponseBody.fromString(
            '{"message": "temporary overload"}',
            503,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString(
          '{"status": "ok"}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      dio.interceptors.add(
        UspsRetryInterceptor(
          dio: dio,
          maxRetries: 3,
          initialDelay: const Duration(milliseconds: 10),
          sleeper: (d) async => sleepDelays.add(d),
        ),
      );

      final response = await dio.get<Map<String, dynamic>>('/test-retry');
      expect(response.statusCode, equals(200));
      expect(callCount, equals(2));
      expect(sleepDelays.length, equals(1));
    });

    test('stops retrying when maxRetries is exceeded', () async {
      dio.httpClientAdapter = _MockAdapter((options) {
        callCount++;
        return ResponseBody.fromString(
          '{"message": "rate limit exceeded"}',
          429,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      dio.interceptors.add(
        UspsRetryInterceptor(
          dio: dio,
          maxRetries: 2,
          initialDelay: const Duration(milliseconds: 5),
          sleeper: (d) async => sleepDelays.add(d),
        ),
      );

      await expectLater(
        () => dio.get<Map<String, dynamic>>('/rate-limited'),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'statusCode',
            equals(429),
          ),
        ),
      );

      // Initial call + 2 retries = 3 calls
      expect(callCount, equals(3));
      expect(sleepDelays.length, equals(2));
    });

    test('does not retry non-idempotent POST methods', () async {
      dio.httpClientAdapter = _MockAdapter((options) {
        callCount++;
        return ResponseBody.fromString(
          '{"message": "server error"}',
          500,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      dio.interceptors.add(
        UspsRetryInterceptor(
          dio: dio,
          maxRetries: 3,
          initialDelay: const Duration(milliseconds: 5),
          sleeper: (d) async => sleepDelays.add(d),
        ),
      );

      await expectLater(
        () => dio.post<Map<String, dynamic>>('/submit-order'),
        throwsA(isA<DioException>()),
      );

      expect(callCount, equals(1));
      expect(sleepDelays, isEmpty);
    });

    test('does not retry non-transient 400 Bad Request error', () async {
      dio.httpClientAdapter = _MockAdapter((options) {
        callCount++;
        return ResponseBody.fromString(
          '{"message": "invalid input parameters"}',
          400,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      dio.interceptors.add(
        UspsRetryInterceptor(
          dio: dio,
          maxRetries: 3,
          sleeper: (d) async => sleepDelays.add(d),
        ),
      );

      await expectLater(
        () => dio.get<Map<String, dynamic>>('/bad-request'),
        throwsA(isA<DioException>()),
      );

      expect(callCount, equals(1));
      expect(sleepDelays, isEmpty);
    });

    test('retries on network timeout exceptions', () async {
      dio.httpClientAdapter = _MockAdapter((options) {
        callCount++;
        if (callCount == 1) {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionTimeout,
            message: 'Connection timed out',
          );
        }
        return ResponseBody.fromString(
          '{"data": "recovered"}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      dio.interceptors.add(
        UspsRetryInterceptor(
          dio: dio,
          maxRetries: 2,
          initialDelay: const Duration(milliseconds: 5),
          sleeper: (d) async => sleepDelays.add(d),
        ),
      );

      final response = await dio.get<Map<String, dynamic>>('/timeout-endpoint');
      expect(response.statusCode, equals(200));
      expect(callCount, equals(2));
      expect(sleepDelays.length, equals(1));
    });

    test('passes error down the chain if unexpected non-Dio exception occurs during retry', () async {
      int attempts = 0;
      dio.httpClientAdapter = _MockAdapter((options) {
        attempts++;
        if (attempts == 1) {
          return ResponseBody.fromString(
            '{"message": "server busy"}',
            503,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        throw StateError('Simulated unexpected failure during retry attempt');
      });

      dio.interceptors.add(
        UspsRetryInterceptor(
          dio: dio,
          maxRetries: 2,
          initialDelay: const Duration(milliseconds: 5),
          sleeper: (d) async => sleepDelays.add(d),
        ),
      );

      await expectLater(
        () => dio.get<Map<String, dynamic>>('/unexpected-crash'),
        throwsA(isA<DioException>()),
      );
    });
  });
}

class _MockAdapter implements HttpClientAdapter {
  final ResponseBody Function(RequestOptions options) handler;

  _MockAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}
