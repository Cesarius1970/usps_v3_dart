import '../../../core/exceptions/usps_exceptions.dart';
import '../../../core/network/usps_http_client.dart';
import '../models/location_models.dart';

/// Repository for discovering USPS facilities, Post Offices, and collection boxes.
class LocationsRepository {
  final UspsHttpClient _client;

  /// Creates a new [LocationsRepository] with the provided [_client].
  LocationsRepository(this._client);

  /// Searches for USPS facilities near a [zipCode] or geographic coordinates ([latitude], [longitude]).
  ///
  /// [maxResults] limits the maximum number of facilities returned (default 10).
  /// [radius] specifies the search radius in miles.
  Future<LocationsResponse> findLocations({
    String? zipCode,
    double? latitude,
    double? longitude,
    int maxResults = 10,
    double? radius,
  }) async {
    final queryParameters = <String, dynamic>{'maxResults': maxResults};

    if (zipCode != null) queryParameters['zipCode'] = zipCode;
    if (latitude != null) queryParameters['latitude'] = latitude;
    if (longitude != null) queryParameters['longitude'] = longitude;
    if (radius != null) queryParameters['radius'] = radius;

    final response = await _client.get<dynamic>(
      '/locations/v3/locations',
      queryParameters: queryParameters,
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return LocationsResponse.fromJson(data);
    } else if (data is List) {
      final list = data
          .whereType<Map<String, dynamic>>()
          .map(UspsLocation.fromJson)
          .toList();
      return LocationsResponse(locations: list, totalLocations: list.length);
    }

    throw const UspsUnknownException(
      message: 'Unexpected payload format received from locations endpoint',
    );
  }
}
