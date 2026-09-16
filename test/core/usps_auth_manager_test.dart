import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:usps_v3_dart/src/core/auth/models/oauth_token.dart';
import 'package:usps_v3_dart/src/core/auth/usps_auth_manager.dart';
import 'package:usps_v3_dart/src/core/environment/usps_environment.dart';
import 'package:usps_v3_dart/src/core/exceptions/usps_exceptions.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockAuthDio;
  late UspsAuthManager authManager;
  late Map<String, dynamic> tokenJson;

  setUp(() {
    mockAuthDio = MockDio();
    authManager = UspsAuthManager(
      clientId: 'test_client_id',
      clientSecret: 'test_client_secret',
      environment: UspsEnvironment.sandbox,
      authDio: mockAuthDio,
    );

    final fixtureFile = File('test/fixtures/oauth_token_success.json');
    tokenJson =
        jsonDecode(fixtureFile.readAsStringSync()) as Map<String, dynamic>;
  });

  group('OAuthToken Model', () {
    test('deserializes, serializes, and computes expiration correctly', () {
      final token = OAuthToken.fromJson(tokenJson);

      expect(token.accessToken, equals('mock_usps_bearer_token_xyz_123'));
      expect(token.tokenType, equals('Bearer'));
      expect(token.expiresIn, equals(28799));
      expect(token.status, equals('approved'));
      expect(token.scope, equals('tracking addresses locations pricing shipping'));
      expect(token.isExpired(), isFalse);
      expect(token.isExpired(const Duration(seconds: 0)), isFalse);

      final jsonOut = token.toJson();
      expect(jsonOut['access_token'], equals('mock_usps_bearer_token_xyz_123'));
      expect(jsonOut['token_type'], equals('Bearer'));
      expect(jsonOut['expires_in'], equals(28799));

      final expiredToken = OAuthToken(
        accessToken: 'expired',
        tokenType: 'Bearer',
        expiresIn: 30,
        issuedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );
      expect(expiredToken.isExpired(), isTrue);
    });
  });

  group('UspsAuthManager', () {
    test('instantiates with default authDio and custom tokenEndpoint', () {
      final customManager = UspsAuthManager(
        clientId: 'id',
        clientSecret: 'sec',
        tokenEndpoint: 'https://custom.endpoint.com/token',
      );
      expect(customManager.tokenEndpoint, equals('https://custom.endpoint.com/token'));
      expect(customManager.isAuthenticated, isFalse);
      expect(customManager.currentToken, isNull);
    });

    test('fetches new token successfully when cache is empty', () async {
      when(
        () => mockAuthDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: tokenJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/oauth2/v3/token'),
        ),
      );

      final token = await authManager.getValidToken();

      expect(token, equals('mock_usps_bearer_token_xyz_123'));
      expect(authManager.isAuthenticated, isTrue);
      expect(
        authManager.currentToken?.accessToken,
        equals('mock_usps_bearer_token_xyz_123'),
      );

      verify(
        () => mockAuthDio.post<Map<String, dynamic>>(
          'https://api-cat.usps.com/oauth2/v3/token',
          data: {
            'client_id': 'test_client_id',
            'client_secret': 'test_client_secret',
            'grant_type': 'client_credentials',
          },
        ),
      ).called(1);
    });

    test('reuses in-flight request when multiple concurrent calls occur', () async {
      final completer = Completer<Response<Map<String, dynamic>>>();

      when(
        () => mockAuthDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) => completer.future);

      final future1 = authManager.getValidToken();
      final future2 = authManager.getValidToken();

      completer.complete(
        Response(
          data: tokenJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/oauth2/v3/token'),
        ),
      );

      final results = await Future.wait([future1, future2]);
      expect(results[0], equals('mock_usps_bearer_token_xyz_123'));
      expect(results[1], equals('mock_usps_bearer_token_xyz_123'));

      // HTTP call was made only once despite 2 simultaneous callers
      verify(
        () => mockAuthDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
        ),
      ).called(1);
    });

    test('reuses cached token without invoking HTTP again', () async {
      when(
        () => mockAuthDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: tokenJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/oauth2/v3/token'),
        ),
      );

      final token1 = await authManager.getValidToken();
      final token2 = await authManager.getValidToken();

      expect(token1, equals(token2));
      verify(
        () => mockAuthDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
        ),
      ).called(1);
    });

    test('forceRefresh: true requests a new token even when cached', () async {
      when(
        () => mockAuthDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: tokenJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/oauth2/v3/token'),
        ),
      );

      await authManager.getValidToken();
      await authManager.getValidToken(forceRefresh: true);

      verify(
        () => mockAuthDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
        ),
      ).called(2);
    });

    test('clearToken resets the in-memory cache', () async {
      when(
        () => mockAuthDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: tokenJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/oauth2/v3/token'),
        ),
      );

      await authManager.getValidToken();
      expect(authManager.isAuthenticated, isTrue);

      authManager.clearToken();
      expect(authManager.isAuthenticated, isFalse);
      expect(authManager.currentToken, isNull);
    });

    test('throws UspsAuthException when response data is null', () async {
      when(
        () => mockAuthDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: null,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/oauth2/v3/token'),
        ),
      );

      expect(
        () => authManager.getValidToken(),
        throwsA(
          isA<UspsAuthException>().having(
            (e) => e.message,
            'message',
            contains('Received empty response body'),
          ),
        ),
      );
    });

    test('throws UspsAuthException when USPS returns error with error_description', () async {
      when(
        () => mockAuthDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/oauth2/v3/token'),
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 401,
            data: {'error_description': 'Invalid client credentials'},
            requestOptions: RequestOptions(path: '/oauth2/v3/token'),
          ),
        ),
      );

      expect(
        () => authManager.getValidToken(),
        throwsA(
          isA<UspsAuthException>()
              .having((e) => e.statusCode, 'statusCode', equals(401))
              .having(
                (e) => e.message,
                'message',
                equals('Invalid client credentials'),
              ),
        ),
      );
    });

    test('extracts error from error key in response data', () async {
      when(
        () => mockAuthDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/oauth2/v3/token'),
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 400,
            data: {'error': 'unsupported_grant_type'},
            requestOptions: RequestOptions(path: '/oauth2/v3/token'),
          ),
        ),
      );

      expect(
        () => authManager.getValidToken(),
        throwsA(
          isA<UspsAuthException>().having(
            (e) => e.message,
            'message',
            equals('unsupported_grant_type'),
          ),
        ),
      );
    });

    test('extracts error from message key in response data', () async {
      when(
        () => mockAuthDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/oauth2/v3/token'),
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 403,
            data: {'message': 'Quota exceeded'},
            requestOptions: RequestOptions(path: '/oauth2/v3/token'),
          ),
        ),
      );

      expect(
        () => authManager.getValidToken(),
        throwsA(
          isA<UspsAuthException>().having(
            (e) => e.message,
            'message',
            equals('Quota exceeded'),
          ),
        ),
      );
    });

    test('wraps non-DioException during token fetch into UspsAuthException', () async {
      when(
        () => mockAuthDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
        ),
      ).thenThrow(StateError('Unexpected IO error'));

      expect(
        () => authManager.getValidToken(),
        throwsA(
          isA<UspsAuthException>().having(
            (e) => e.message,
            'message',
            contains('Unexpected error during token acquisition: Bad state: Unexpected IO error'),
          ),
        ),
      );
    });
  });
}
