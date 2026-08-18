import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:usps_v3_dart/src/core/exceptions/usps_exceptions.dart';
import 'package:usps_v3_dart/src/core/network/usps_http_client.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late UspsHttpClient client;

  setUp(() {
    mockDio = MockDio();
    when(() => mockDio.interceptors).thenReturn(Interceptors());
    client = UspsHttpClient(dio: mockDio);
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

    test('maps 401 Unauthorized to UspsAuthException', () async {
      when(() => mockDio.get<dynamic>(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/protected'),
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 401,
            data: {
              'error': {
                'code': 'UNAUTHORIZED',
                'message': 'Invalid OAuth token',
              },
            },
            requestOptions: RequestOptions(path: '/protected'),
          ),
        ),
      );

      expect(
        () => client.get<dynamic>('/protected'),
        throwsA(
          isA<UspsAuthException>()
              .having((e) => e.statusCode, 'statusCode', equals(401))
              .having(
                (e) => e.message,
                'message',
                equals('Invalid OAuth token'),
              ),
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

    test('maps unexpected exceptions to UspsUnknownException', () async {
      when(
        () => mockDio.get<dynamic>(any()),
      ).thenThrow(Exception('Unexpected system failure'));

      expect(
        () => client.get<dynamic>('/crash'),
        throwsA(isA<UspsUnknownException>()),
      );
    });
  });
}
