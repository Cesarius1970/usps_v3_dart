import 'package:dio/dio.dart';

import '../exceptions/usps_exceptions.dart';

/// Low-level HTTP client wrapping [Dio] with USPS-specific configuration,
/// header handling, timeouts, and exception translation.
class UspsHttpClient {
  /// The underlying [Dio] instance.
  final Dio dio;

  /// Creates a new [UspsHttpClient].
  ///
  /// If [dio] is not provided, a default configured instance will be created with
  /// [baseUrl], [connectTimeout], and [receiveTimeout].
  UspsHttpClient({
    Dio? dio,
    String? baseUrl,
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
    Duration sendTimeout = const Duration(seconds: 30),
  }) : dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl ?? '',
               connectTimeout: connectTimeout,
               receiveTimeout: receiveTimeout,
               sendTimeout: sendTimeout,
               headers: {
                 'Accept': 'application/json',
                 'Content-Type': 'application/json',
               },
             ),
           );

  /// Adds a Dio interceptor to the client pipeline.
  void addInterceptor(Interceptor interceptor) {
    dio.interceptors.add(interceptor);
  }

  /// Closes the underlying [Dio] client and its HTTP connection pool.
  void close({bool force = false}) {
    dio.close(force: force);
  }

  /// Sends an HTTP GET request to [path].
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _send(
      () => dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  /// Sends an HTTP POST request to [path] with [data].
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _send(
      () => dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  /// Sends an HTTP PUT request to [path] with [data].
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _send(
      () => dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  /// Sends an HTTP DELETE request to [path].
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _send(
      () => dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  /// Executes an HTTP operation and maps any [DioException] to the appropriate [UspsException].
  Future<Response<T>> _send<T>(Future<Response<T>> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw _transformDioException(e);
    } catch (e, stackTrace) {
      if (e is UspsException) rethrow;
      throw UspsUnknownException(
        message: 'An unexpected error occurred during HTTP request: $e',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Converts a [DioException] into a domain-specific [UspsException].
  UspsException _transformDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return UspsNetworkException(
          message: e.message ?? 'Network connection failure or timeout',
          cause: e,
        );

      case DioExceptionType.badResponse:
        final response = e.response;
        final statusCode = response?.statusCode;
        final dynamic responseData = response?.data;

        String message = 'HTTP $statusCode: ${e.message}';
        String? errorCode;

        if (responseData is Map<String, dynamic>) {
          // USPS v3 error response structure parsing (e.g. error.message, error.code or errors array)
          final errorObj = responseData['error'];
          if (errorObj is Map<String, dynamic>) {
            message =
                errorObj['message']?.toString() ??
                errorObj['detail']?.toString() ??
                message;
            errorCode = errorObj['code']?.toString();
          } else if (responseData['errors'] is List &&
              (responseData['errors'] as List).isNotEmpty) {
            final firstError = (responseData['errors'] as List).first;
            if (firstError is Map<String, dynamic>) {
              message =
                  firstError['detail']?.toString() ??
                  firstError['message']?.toString() ??
                  message;
              errorCode =
                  firstError['code']?.toString() ??
                  firstError['status']?.toString();
            }
          } else if (responseData['message'] != null) {
            message = responseData['message'].toString();
          }
        }

        if (statusCode == 401 || statusCode == 403) {
          return UspsAuthException(
            message: message,
            statusCode: statusCode,
            data: responseData,
          );
        }

        return UspsApiException(
          message: message,
          statusCode: statusCode,
          data: responseData,
          errorCode: errorCode,
        );

      case DioExceptionType.cancel:
        return const UspsNetworkException(message: 'Request was cancelled');

      case DioExceptionType.badCertificate:
        return UspsNetworkException(
          message: 'Bad SSL/TLS certificate',
          cause: e,
        );

      case DioExceptionType.unknown:
      default:
        return UspsUnknownException(
          message: e.message ?? 'Unknown HTTP error occurred',
          cause: e,
        );
    }
  }
}
