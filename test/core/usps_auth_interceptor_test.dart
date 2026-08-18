import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:usps_v3_dart/src/core/auth/usps_auth_manager.dart';
import 'package:usps_v3_dart/src/core/network/usps_auth_interceptor.dart';

class MockAuthManager extends Mock implements UspsAuthManager {}

class MockDio extends Mock implements Dio {}

class MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

void main() {
  late MockAuthManager mockAuthManager;
  late MockDio mockDio;
  late UspsAuthInterceptor interceptor;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/fallback'));
    registerFallbackValue(
      Response<dynamic>(requestOptions: RequestOptions(path: '/fallback')),
    );
    registerFallbackValue(
      DioException(requestOptions: RequestOptions(path: '/fallback')),
    );
  });

  setUp(() {
    mockAuthManager = MockAuthManager();
    mockDio = MockDio();
    interceptor = UspsAuthInterceptor(
      authManager: mockAuthManager,
      dio: mockDio,
    );
  });

  group('UspsAuthInterceptor onRequest', () {
    test('attaches Bearer token to request headers', () async {
      when(
        () => mockAuthManager.getValidToken(),
      ).thenAnswer((_) async => 'bearer_12345');

      final options = RequestOptions(path: '/v3/tracking/123');
      final handler = MockRequestInterceptorHandler();

      interceptor.onRequest(options, handler);

      // Allow microtask queue to process async body
      await Future<void>.delayed(Duration.zero);

      expect(options.headers['Authorization'], equals('Bearer bearer_12345'));
      verify(() => handler.next(options)).called(1);
    });

    test('rejects request if token acquisition fails', () async {
      when(
        () => mockAuthManager.getValidToken(),
      ).thenThrow(Exception('Auth server down'));

      final options = RequestOptions(path: '/v3/tracking/123');
      final handler = MockRequestInterceptorHandler();

      interceptor.onRequest(options, handler);
      await Future<void>.delayed(Duration.zero);

      verify(() => handler.reject(any())).called(1);
    });
  });

  group('UspsAuthInterceptor onError', () {
    test('forces refresh and retries request on 401 Unauthorized', () async {
      final requestOptions = RequestOptions(path: '/v3/tracking/123');
      final error = DioException(
        requestOptions: requestOptions,
        response: Response(statusCode: 401, requestOptions: requestOptions),
      );

      final retryResponse = Response<dynamic>(
        statusCode: 200,
        data: {'trackingNumber': '123'},
        requestOptions: requestOptions,
      );

      when(
        () => mockAuthManager.getValidToken(forceRefresh: true),
      ).thenAnswer((_) async => 'refreshed_token_abc');
      when(
        () => mockDio.fetch<dynamic>(requestOptions),
      ).thenAnswer((_) async => retryResponse);

      final handler = MockErrorInterceptorHandler();
      interceptor.onError(error, handler);

      await Future<void>.delayed(Duration.zero);

      expect(
        requestOptions.headers['Authorization'],
        equals('Bearer refreshed_token_abc'),
      );
      verify(() => mockAuthManager.getValidToken(forceRefresh: true)).called(1);
      verify(() => mockDio.fetch<dynamic>(requestOptions)).called(1);
      verify(() => handler.resolve(retryResponse)).called(1);
    });

    test('passes error down the chain for non-401 errors', () async {
      final requestOptions = RequestOptions(path: '/v3/tracking/123');
      final error = DioException(
        requestOptions: requestOptions,
        response: Response(statusCode: 404, requestOptions: requestOptions),
      );

      final handler = MockErrorInterceptorHandler();
      interceptor.onError(error, handler);

      await Future<void>.delayed(Duration.zero);

      verifyNever(() => mockAuthManager.getValidToken(forceRefresh: true));
      verify(() => handler.next(error)).called(1);
    });
  });
}
