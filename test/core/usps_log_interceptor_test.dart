import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:usps_v3_dart/usps_v3_dart.dart';

void main() {
  group('UspsLogInterceptor', () {
    late List<String> logs;
    late Dio dio;

    setUp(() {
      logs = [];
      dio = Dio();
      dio.interceptors.add(
        UspsLogInterceptor(
          logPrint: (msg) => logs.add(msg),
        ),
      );
    });

    test('logs request headers with sanitized token and body', () async {
      dio.httpClientAdapter = _MockAdapter((options) {
        return ResponseBody.fromString(
          '{"status": "OK", "access_token": "secret_token_val"}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      await dio.post<Map<String, dynamic>>(
        '/oauth/token',
        options: Options(
          headers: {'Authorization': 'Bearer my-bearer-token'},
        ),
        data: {
          'client_id': 'id123',
          'client_secret': 'secret123',
          'grant_type': 'client_credentials',
        },
      );

      expect(logs.any((l) => l.contains('Bearer [REDACTED]')), isTrue);
      expect(logs.any((l) => l.contains('my-bearer-token')), isFalse);
      expect(logs.any((l) => l.contains('[REDACTED]')), isTrue);
      expect(logs.any((l) => l.contains('secret123')), isFalse);
      expect(logs.any((l) => l.contains('secret_token_val')), isFalse);
    });

    test('logs error details and status code', () async {
      dio.httpClientAdapter = _MockAdapter((options) {
        return ResponseBody.fromString(
          '{"message": "rate limit exceeded"}',
          429,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      await expectLater(
        () => dio.get<Map<String, dynamic>>('/rate-limit'),
        throwsA(isA<DioException>()),
      );

      expect(logs.any((l) => l.contains('*** USPS Error [429]')), isTrue);
      expect(logs.any((l) => l.contains('rate limit exceeded')), isTrue);
    });

    test('default constructor with null logPrint outputs to print', () async {
      final defaultDio = Dio();
      defaultDio.interceptors.add(UspsLogInterceptor());
      defaultDio.httpClientAdapter = _MockAdapter((options) {
        return ResponseBody.fromString(
          '{"status": "ok"}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final printed = <String>[];
      await runZoned(
        () => defaultDio.get<dynamic>('/test-default-print'),
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, line) {
            printed.add(line);
          },
        ),
      );

      expect(printed.isNotEmpty, isTrue);
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
