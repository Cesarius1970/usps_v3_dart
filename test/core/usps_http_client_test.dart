import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:usps_v3_dart/src/core/exceptions/usps_exceptions.dart';
import 'package:usps_v3_dart/src/core/network/usps_http_client.dart';

class MockDio extends Mock implements Dio {}
class MockInterceptor extends Mock implements Interceptor {}

void main() {
  late MockDio mockDio;
  late UspsHttpClient client;

  setUp(() {
    mockDio = MockDio();
    when(() => mockDio.interceptors).thenReturn(Interceptors());
    client = UspsHttpClient(dio: mockDio);
  });

  group('UspsHttpClient Initialization & Interceptors', () {
    test('instantiates with default internal Dio when none provided', () {
      final defaultClient = UspsHttpClient(baseUrl: 'https://api.usps.com');
      expect(defaultClient.dio.options.baseUrl, equals('https://api.usps.com'));
      expect(defaultClient.dio.options.headers['Content-Type'], equals('application/json'));
    });

    test('addInterceptor successfully registers an interceptor', () {
      final interceptor = MockInterceptor();
      client.addInterceptor(interceptor);
      expect(client.dio.interceptors, contains(interceptor));
    });
  });

  group('UspsHttpClient Successful Requests', () {
    test('GET request forwards parameters and returns response', () async {
      final response = Response<Map<String, dynamic>>(
        data: {'status': 'OK'},
        statusCode: 200,
        requestOptions: RequestOptions(path: '/test'),
      );

      when(
        () => mockDio.get<Map<String, dynamic>>(
          '/test',
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => response);

      final result = await client.get<Map<String, dynamic>>(
        '/test',
        queryParameters: {'expand': 'DETAIL'},
      );

      expect(result.statusCode, equals(200));
      expect(result.data?['status'], equals('OK'));
    });

    test('POST request forwards data and returns response', () async {
      final response = Response<Map<String, dynamic>>(
        data: {'trackingNumber': '12345'},
        statusCode: 201,
        requestOptions: RequestOptions(path: '/labels'),
      );

      when(
        () => mockDio.post<Map<String, dynamic>>(
          '/labels',
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => response);

      final result = await client.post<Map<String, dynamic>>(
        '/labels',
        data: {'weight': 1.0},
      );

      expect(result.statusCode, equals(201));
      expect(result.data?['trackingNumber'], equals('12345'));
    });

    test('PUT request forwards data and returns response', () async {
      final response = Response<Map<String, dynamic>>(
        data: {'updated': true},
        statusCode: 200,
        requestOptions: RequestOptions(path: '/update'),
      );

      when(
        () => mockDio.put<Map<String, dynamic>>(
          '/update',
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => response);

      final result = await client.put<Map<String, dynamic>>(
        '/update',
        data: {'key': 'val'},
      );

      expect(result.statusCode, equals(200));
      expect(result.data?['updated'], isTrue);
    });

    test('DELETE request returns response', () async {
      final response = Response<Map<String, dynamic>>(
        data: {'deleted': true},
        statusCode: 200,
        requestOptions: RequestOptions(path: '/delete'),
      );

      when(
        () => mockDio.delete<Map<String, dynamic>>(
          '/delete',
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => response);

      final result = await client.delete<Map<String, dynamic>>('/delete');

      expect(result.statusCode, equals(200));
      expect(result.data?['deleted'], isTrue);
    });
  });

  group('UspsHttpClient Error Handling & Mapping', () {
    test('maps connection timeout to UspsNetworkException', () async {
      when(() => mockDio.get<dynamic>(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/timeout'),
          type: DioExceptionType.connectionTimeout,
          message: 'Connection timed out',
        ),
      );

      expect(
        () => client.get<dynamic>('/timeout'),
        throwsA(
          isA<UspsNetworkException>().having(
            (e) => e.message,
            'message',
            contains('Connection timed out'),
          ),
        ),
      );
    });

    test('maps sendTimeout, receiveTimeout, and connectionError to UspsNetworkException', () async {
      when(() => mockDio.get<dynamic>('/send')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/send'),
          type: DioExceptionType.sendTimeout,
          message: 'Send timeout',
        ),
      );
      when(() => mockDio.get<dynamic>('/receive')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/receive'),
          type: DioExceptionType.receiveTimeout,
          message: 'Receive timeout',
        ),
      );
      when(() => mockDio.get<dynamic>('/conn')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/conn'),
          type: DioExceptionType.connectionError,
          message: 'Connection error',
        ),
      );

      expect(() => client.get<dynamic>('/send'), throwsA(isA<UspsNetworkException>()));
      expect(() => client.get<dynamic>('/receive'), throwsA(isA<UspsNetworkException>()));
      expect(() => client.get<dynamic>('/conn'), throwsA(isA<UspsNetworkException>()));
    });

    test('maps cancel and badCertificate to UspsNetworkException', () async {
      when(() => mockDio.get<dynamic>('/cancel')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/cancel'),
          type: DioExceptionType.cancel,
        ),
      );
      when(() => mockDio.get<dynamic>('/bad-cert')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/bad-cert'),
          type: DioExceptionType.badCertificate,
        ),
      );

      expect(
        () => client.get<dynamic>('/cancel'),
        throwsA(
          isA<UspsNetworkException>().having(
            (e) => e.message,
            'message',
            equals('Request was cancelled'),
          ),
        ),
      );
      expect(
        () => client.get<dynamic>('/bad-cert'),
        throwsA(
          isA<UspsNetworkException>().having(
            (e) => e.message,
            'message',
            equals('Bad SSL/TLS certificate'),
          ),
        ),
      );
    });

    test('maps unknown DioException to UspsUnknownException', () async {
      when(() => mockDio.get<dynamic>('/unknown')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/unknown'),
          type: DioExceptionType.unknown,
          message: 'Mystery error',
        ),
      );

      expect(
        () => client.get<dynamic>('/unknown'),
        throwsA(
          isA<UspsUnknownException>().having(
            (e) => e.message,
            'message',
            equals('Mystery error'),
          ),
        ),
      );
    });

    test('maps 401 and 403 to UspsAuthException', () async {
      when(() => mockDio.get<dynamic>('/protected-401')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/protected-401'),
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 401,
            data: {
              'error': {
                'code': 'UNAUTHORIZED',
                'message': 'Invalid OAuth token',
              },
            },
            requestOptions: RequestOptions(path: '/protected-401'),
          ),
        ),
      );

      when(() => mockDio.get<dynamic>('/protected-403')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/protected-403'),
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 403,
            data: {
              'error': {
                'detail': 'Forbidden access',
              },
            },
            requestOptions: RequestOptions(path: '/protected-403'),
          ),
        ),
      );

      expect(
        () => client.get<dynamic>('/protected-401'),
        throwsA(
          isA<UspsAuthException>()
              .having((e) => e.statusCode, 'statusCode', equals(401))
              .having((e) => e.message, 'message', equals('Invalid OAuth token')),
        ),
      );

      expect(
        () => client.get<dynamic>('/protected-403'),
        throwsA(
          isA<UspsAuthException>()
              .having((e) => e.statusCode, 'statusCode', equals(403))
              .having((e) => e.message, 'message', equals('Forbidden access')),
        ),
      );
    });

    test('maps 400 Bad Request with error list to UspsApiException', () async {
      when(() => mockDio.get<dynamic>(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/addresses'),
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 400,
            data: {
              'errors': [
                {'code': 'INVALID_ZIP', 'detail': 'Invalid ZIP code provided'},
              ],
            },
            requestOptions: RequestOptions(path: '/addresses'),
          ),
        ),
      );

      expect(
        () => client.get<dynamic>('/addresses'),
        throwsA(
          isA<UspsApiException>()
              .having((e) => e.statusCode, 'statusCode', equals(400))
              .having((e) => e.errorCode, 'errorCode', equals('INVALID_ZIP'))
              .having(
                (e) => e.message,
                'message',
                equals('Invalid ZIP code provided'),
              ),
        ),
      );
    });

    test('maps 400 with errors list having message and status keys', () async {
      when(() => mockDio.get<dynamic>('/status-key')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/status-key'),
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 400,
            data: {
              'errors': [
                {'message': 'Malformed parameter', 'status': '400_BAD'},
              ],
            },
            requestOptions: RequestOptions(path: '/status-key'),
          ),
        ),
      );

      expect(
        () => client.get<dynamic>('/status-key'),
        throwsA(
          isA<UspsApiException>()
              .having((e) => e.errorCode, 'errorCode', equals('400_BAD'))
              .having((e) => e.message, 'message', equals('Malformed parameter')),
        ),
      );
    });

    test('maps response with top-level message string to UspsApiException', () async {
      when(() => mockDio.get<dynamic>('/msg-only')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/msg-only'),
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 500,
            data: {'message': 'Internal USPS gateway failure'},
            requestOptions: RequestOptions(path: '/msg-only'),
          ),
        ),
      );

      expect(
        () => client.get<dynamic>('/msg-only'),
        throwsA(
          isA<UspsApiException>().having(
            (e) => e.message,
            'message',
            equals('Internal USPS gateway failure'),
          ),
        ),
      );
    });

    test('maps unexpected non-Dio exceptions to UspsUnknownException', () async {
      when(
        () => mockDio.get<dynamic>(any()),
      ).thenThrow(Exception('Unexpected system failure'));

      expect(
        () => client.get<dynamic>('/crash'),
        throwsA(isA<UspsUnknownException>()),
      );
    });

    test('rethrows existing UspsException directly without rewrapping', () async {
      when(
        () => mockDio.get<dynamic>(any()),
      ).thenThrow(const UspsNetworkException(message: 'Already UspsException'));

      expect(
        () => client.get<dynamic>('/rethrow'),
        throwsA(
          isA<UspsNetworkException>().having(
            (e) => e.message,
            'message',
            equals('Already UspsException'),
          ),
        ),
      );
    });
  });
}
