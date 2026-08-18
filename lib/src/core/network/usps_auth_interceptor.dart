import 'package:dio/dio.dart';

import '../auth/usps_auth_manager.dart';

/// Dio interceptor that automatically attaches the OAuth 2.0 Bearer token to outgoing requests
/// and seamlessly handles 401 Unauthorized responses by refreshing the token and retrying the request.
class UspsAuthInterceptor extends QueuedInterceptor {
  /// The [UspsAuthManager] handling token lifecycle and caching.
  final UspsAuthManager authManager;

  /// The main [Dio] client used to retry requests upon token refresh.
  final Dio dio;

  /// Creates a new [UspsAuthInterceptor].
  UspsAuthInterceptor({required this.authManager, required this.dio});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await authManager.getValidToken();
      options.headers['Authorization'] = 'Bearer $token';
      handler.next(options);
    } catch (e) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: e,
          message: 'Failed to acquire Bearer token before request execution',
        ),
      );
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only intercept 401 Unauthorized errors for automatic retry
    if (err.response?.statusCode == 401) {
      try {
        // Force refresh the token
        final newToken = await authManager.getValidToken(forceRefresh: true);

        // Update headers for retry
        final requestOptions = err.requestOptions;
        requestOptions.headers['Authorization'] = 'Bearer $newToken';

        // Re-execute the request with the refreshed token
        final response = await dio.fetch<dynamic>(requestOptions);
        return handler.resolve(response);
      } catch (_) {
        // If refreshing or retry fails, continue passing the error down the chain
        return handler.next(err);
      }
    }

    return handler.next(err);
  }
}
