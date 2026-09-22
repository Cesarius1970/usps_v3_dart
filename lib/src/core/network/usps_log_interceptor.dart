import 'package:dio/dio.dart';

/// Interceptor that safely logs outgoing requests, responses, and errors,
/// automatically redacting sensitive tokens and credentials.
class UspsLogInterceptor extends Interceptor {
  /// The callback function used to print log messages.
  final void Function(String message) logPrint;

  /// Whether to log request headers.
  final bool requestHeader;

  /// Whether to log request body.
  final bool requestBody;

  /// Whether to log response body.
  final bool responseBody;

  /// Creates a new [UspsLogInterceptor].
  UspsLogInterceptor({
    void Function(String message)? logPrint,
    this.requestHeader = true,
    this.requestBody = true,
    this.responseBody = true,
  }) : logPrint = logPrint ?? _defaultLogPrint;

  static void _defaultLogPrint(String message) {
    // ignore: avoid_print
    print(message);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logPrint('*** USPS Request: ${options.method} ${options.uri} ***');
    if (requestHeader) {
      final sanitizedHeaders = Map<String, dynamic>.from(options.headers);
      if (sanitizedHeaders.containsKey('Authorization')) {
        sanitizedHeaders['Authorization'] = 'Bearer [REDACTED]';
      }
      logPrint('Headers: $sanitizedHeaders');
    }
    if (requestBody && options.data != null) {
      logPrint('Body: ${_sanitizeData(options.data)}');
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    logPrint(
      '*** USPS Response [${response.statusCode}] ${response.requestOptions.method} ${response.requestOptions.uri} ***',
    );
    if (responseBody && response.data != null) {
      logPrint('Data: ${_sanitizeData(response.data)}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logPrint(
      '*** USPS Error [${err.response?.statusCode ?? 'N/A'}] ${err.requestOptions.method} ${err.requestOptions.uri} ***',
    );
    logPrint('Error Message: ${err.message}');
    if (err.response?.data != null) {
      logPrint('Error Data: ${_sanitizeData(err.response!.data)}');
    }
    handler.next(err);
  }

  dynamic _sanitizeData(dynamic data) {
    if (data is Map<String, dynamic>) {
      final copy = Map<String, dynamic>.from(data);
      if (copy.containsKey('client_secret')) {
        copy['client_secret'] = '[REDACTED]';
      }
      if (copy.containsKey('access_token')) {
        copy['access_token'] = '[REDACTED]';
      }
      return copy;
    }
    return data;
  }
}
