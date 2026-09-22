import '../../../core/enums/usps_enums.dart';
import '../../../core/exceptions/usps_exceptions.dart';
import '../../../core/network/usps_http_client.dart';
import '../../../core/utils/usps_validators.dart';
import '../models/tracking_models.dart';

/// Repository for querying USPS Tracking REST APIs (v3).
class TrackingRepository {
  final UspsHttpClient _client;

  /// Creates a new [TrackingRepository] with the provided [_client].
  TrackingRepository(this._client);

  /// Retrieves tracking details for a single package by its [trackingNumber].
  ///
  /// The [expand] parameter can be [TrackingExpand.detail] to return all scan events, or
  /// [TrackingExpand.summary] to return current status only.
  Future<TrackingResponse> getTracking(
    String trackingNumber, {
    TrackingExpand expand = TrackingExpand.detail,
  }) async {
    final validTracking = UspsValidators.requireValidTrackingNumber(
      trackingNumber,
    );
    final response = await _client.get<dynamic>(
      '/tracking/v3/tracking/$validTracking',
      queryParameters: {'expand': expand.value},
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return TrackingResponse.fromJson(data);
    }

    throw const UspsUnknownException(
      message: 'Unexpected payload format received from tracking endpoint',
    );
  }

  /// Retrieves tracking details for multiple packages in a single batch request.
  ///
  /// The [trackingNumbers] list specifies the USPS tracking numbers to query
  /// (maximum 30 per USPS batch limit). The [expand] parameter can be
  /// [TrackingExpand.detail] or [TrackingExpand.summary].
  Future<List<TrackingResponse>> getMultipleTracking(
    List<String> trackingNumbers, {
    TrackingExpand expand = TrackingExpand.summary,
  }) async {
    if (trackingNumbers.isEmpty) {
      return const [];
    }

    for (final number in trackingNumbers) {
      UspsValidators.requireValidTrackingNumber(number);
    }

    final response = await _client.get<dynamic>(
      '/tracking/v3/tracking',
      queryParameters: {
        'trackingNumbers': trackingNumbers.join(','),
        'expand': expand.value,
      },
    );

    final data = response.data;
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(TrackingResponse.fromJson)
          .toList();
    } else if (data is Map<String, dynamic>) {
      if (data['trackResponses'] is List) {
        return (data['trackResponses'] as List)
            .whereType<Map<String, dynamic>>()
            .map(TrackingResponse.fromJson)
            .toList();
      }
      return [TrackingResponse.fromJson(data)];
    }

    throw const UspsUnknownException(
      message:
          'Unexpected batch payload format received from tracking endpoint',
    );
  }
}
