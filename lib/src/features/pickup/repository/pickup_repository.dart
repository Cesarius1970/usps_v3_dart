import '../../../core/exceptions/usps_exceptions.dart';
import '../../../core/network/usps_http_client.dart';
import '../models/pickup_models.dart';

/// Repository for managing USPS Carrier Pickup REST APIs (v3).
class CarrierPickupRepository {
  final UspsHttpClient _client;

  /// Creates a new [CarrierPickupRepository] with the provided [_client].
  CarrierPickupRepository(this._client);

  /// Checks carrier pickup service availability at a specified physical address.
  ///
  /// The [streetAddress] is required, along with either [zipCode] or both [city] and [state].
  Future<CarrierPickupEligibilityResponse> checkEligibility({
    required String streetAddress,
    String? secondaryAddress,
    String? city,
    String? state,
    String? zipCode,
    String? zipPlus4,
    String? urbanization,
  }) async {
    final queryParams = <String, dynamic>{
      'streetAddress': streetAddress,
    };
    if (secondaryAddress != null) {
      queryParams['secondaryAddress'] = secondaryAddress;
    }
    if (city != null) {
      queryParams['city'] = city;
    }
    if (state != null) {
      queryParams['state'] = state;
    }
    if (zipCode != null) {
      queryParams['ZIPCode'] = zipCode;
    }
    if (zipPlus4 != null) {
      queryParams['ZIPPlus4'] = zipPlus4;
    }
    if (urbanization != null) {
      queryParams['urbanization'] = urbanization;
    }

    final response = await _client.get<dynamic>(
      '/pickup/v3/carrier-pickup/eligibility',
      queryParameters: queryParams,
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return CarrierPickupEligibilityResponse.fromJson(data);
    }

    throw const UspsUnknownException(
      message:
          'Unexpected payload format received from carrier pickup eligibility endpoint',
    );
  }

  /// Schedules a new carrier pickup with USPS.
  Future<CarrierPickupResponse> schedulePickup(
    CarrierPickupRequest request,
  ) async {
    final response = await _client.post<dynamic>(
      '/pickup/v3/carrier-pickup',
      data: request.toJson(),
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return CarrierPickupResponse.fromJson(data);
    }

    throw const UspsUnknownException(
      message:
          'Unexpected payload format received from carrier pickup schedule endpoint',
    );
  }

  /// Retrieves details for an existing carrier pickup by its [confirmationNumber].
  Future<CarrierPickupResponse> getPickup(String confirmationNumber) async {
    final response = await _client.get<dynamic>(
      '/pickup/v3/carrier-pickup/$confirmationNumber',
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return CarrierPickupResponse.fromJson(data);
    }

    throw const UspsUnknownException(
      message:
          'Unexpected payload format received from carrier pickup retrieval endpoint',
    );
  }

  /// Updates or modifies an existing carrier pickup.
  Future<CarrierPickupResponse> updatePickup(
    CarrierPickupUpdateRequest request,
  ) async {
    final response = await _client.put<dynamic>(
      '/pickup/v3/carrier-pickup/${request.confirmationNumber}',
      data: request.toJson(),
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return CarrierPickupResponse.fromJson(data);
    }

    throw const UspsUnknownException(
      message:
          'Unexpected payload format received from carrier pickup update endpoint',
    );
  }

  /// Cancels an existing scheduled carrier pickup by its [confirmationNumber].
  Future<bool> cancelPickup(String confirmationNumber) async {
    final response = await _client.delete<dynamic>(
      '/pickup/v3/carrier-pickup/$confirmationNumber',
    );

    final statusCode = response.statusCode;
    return statusCode != null && statusCode >= 200 && statusCode < 300;
  }
}
