import 'package:dio/dio.dart';

import '../environment/usps_environment.dart';
import '../exceptions/usps_exceptions.dart';
import 'models/oauth_token.dart';

/// Manages OAuth 2.0 client credentials authentication, in-memory token caching,
/// proactive renewal before expiration, and on-demand token refreshing.
class UspsAuthManager {
  /// The USPS Application Client ID.
  final String clientId;

  /// The USPS Application Client Secret.
  final String clientSecret;

  /// The OAuth 2.0 token endpoint URL.
  final String tokenEndpoint;

  /// Underlying [Dio] instance dedicated for authentication requests to avoid interceptor recursion.
  final Dio _authDio;

  /// In-memory cached token.
  OAuthToken? _cachedToken;

  /// Future representing an in-flight token request to prevent concurrent duplicate token calls.
  Future<OAuthToken>? _inFlightTokenRequest;

  /// Creates a new [UspsAuthManager].
  UspsAuthManager({
    required this.clientId,
    required this.clientSecret,
    String? tokenEndpoint,
    UspsEnvironment environment = UspsEnvironment.production,
    Dio? authDio,
  }) : tokenEndpoint = tokenEndpoint ?? environment.tokenEndpoint,
       _authDio =
           authDio ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 20),
               receiveTimeout: const Duration(seconds: 20),
               sendTimeout: const Duration(seconds: 20),
               headers: {
                 'Accept': 'application/json',
                 'Content-Type': 'application/json',
               },
             ),
           );

  /// Whether a token is currently cached in memory and not yet expired.
  bool get isAuthenticated =>
      _cachedToken != null && !_cachedToken!.isExpired();

  /// Gets the currently cached [OAuthToken], if any.
  OAuthToken? get currentToken => _cachedToken;

  /// Returns a valid Bearer access token string.
  ///
  /// If a cached token exists and has not expired, it will be returned immediately.
  /// If [forceRefresh] is true or the token is expired/missing, a new token is requested from USPS.
  Future<String> getValidToken({bool forceRefresh = false}) async {
    if (!forceRefresh && isAuthenticated) {
      return _cachedToken!.accessToken;
    }

    // Reuse existing in-flight request if another thread or request is already fetching a token
    if (_inFlightTokenRequest != null) {
      final token = await _inFlightTokenRequest!;
      return token.accessToken;
    }

    try {
      _inFlightTokenRequest = _fetchToken();
      final token = await _inFlightTokenRequest!;
      _cachedToken = token;
      return token.accessToken;
    } finally {
      _inFlightTokenRequest = null;
    }
  }

  /// Clears the in-memory token cache.
  void clearToken() {
    _cachedToken = null;
  }

  /// Internal method to request a new OAuth 2.0 token from the USPS token endpoint.
  Future<OAuthToken> _fetchToken() async {
    try {
      final response = await _authDio.post<Map<String, dynamic>>(
        tokenEndpoint,
        data: {
          'client_id': clientId,
          'client_secret': clientSecret,
          'grant_type': 'client_credentials',
        },
      );

      final data = response.data;
      if (data == null) {
        throw const UspsAuthException(
          message:
              'Received empty response body from USPS OAuth token endpoint',
        );
      }

      return OAuthToken.fromJson(data);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;
      String message = 'Failed to obtain USPS OAuth token: ${e.message}';

      if (responseData is Map<String, dynamic>) {
        message =
            responseData['error_description']?.toString() ??
            responseData['error']?.toString() ??
            responseData['message']?.toString() ??
            message;
      }

      throw UspsAuthException(
        message: message,
        statusCode: statusCode,
        data: responseData,
      );
    } catch (e) {
      if (e is UspsException) rethrow;
      throw UspsAuthException(
        message: 'Unexpected error during token acquisition: $e',
      );
    }
  }
}
